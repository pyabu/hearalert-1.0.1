import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/models/baby_cry_models.dart';
import 'package:mobile_app/services/audio_classifier_service.dart';
import 'package:mobile_app/services/alert_service.dart';
import 'package:mobile_app/services/transcription_service.dart';
import 'package:mobile_app/services/priority_sounds.dart';
import 'package:mobile_app/services/baby_cry_classifier_service.dart';
import 'package:mobile_app/services/baby_cry_dataset_service.dart';
import 'package:mobile_app/providers/settings_provider.dart';

class SoundProvider with ChangeNotifier, WidgetsBindingObserver {
  SettingsProvider? _settings;
  bool _isListening = false;
  bool _shouldBeListening = false; // Track intent separate from state
  // bool _flashlightEnabled = true; // Moved to SettingsProvider
  bool _screenAlertsEnabled = true; // Enabled by default
  double _currentAmplitude = 0.0;
  List<double> _waveformData = [];
  String _transcription = "";
  SoundEvent? _lastEvent;
  final List<SoundEvent> _history = [];
  
  // Services
  final AudioClassifierService _classifier = AudioClassifierService();
  final TranscriptionService _transcriptionService = TranscriptionService();
  final BabyCryClassifierService _babyCryClassifier = BabyCryClassifierService();
  final BabyCryDatasetService _babyCryDataset = BabyCryDatasetService.instance;
  
  StreamSubscription? _detectionSubscription;
  StreamSubscription? _amplitudeSubscription;
  StreamSubscription? _visualizerSubscription;
  StreamSubscription? _transcriptionSubscription;
  StreamSubscription<BabyCryPrediction>? _babyCrySubscription;

  // Baby cry detection state (always enabled automatically)
  BabyCryPrediction? _lastBabyCryDetection;
  List<BabyCryPrediction> _babyCryHistory = [];

  bool get isListening => _isListening;
  bool get flashlightEnabled => _settings?.flashlightEnabled ?? true;
  bool get screenAlertsEnabled => _screenAlertsEnabled; // New setting
  double get amplitude => _currentAmplitude;
  List<double> get waveformData => _waveformData;
  String get transcription => _transcription;
  SoundEvent? get lastEvent => _lastEvent;
  List<SoundEvent> get history => _history;
  List<SoundEvent> get recentEvents => _history.take(5).toList();
  
  // Baby cry getters
  bool get babyCryDetectionEnabled => true; // Always enabled
  BabyCryPrediction? get lastBabyCryDetection => _lastBabyCryDetection;
  List<BabyCryPrediction> get babyCryHistory => _babyCryHistory;

  SoundProvider() {
    WidgetsBinding.instance.addObserver(this);
    // Auto-init and auto-start listening
    _initializeAndAutoStart();
  }
  
  Future<void> _initializeAndAutoStart() async {
    await _classifier.initialize();
    await AlertService().initialize();
    await _babyCryDataset.loadManifest();
    await _babyCryClassifier.initialize();
    
    // Auto-start listening when everything is ready
    debugPrint('🎤 AUTO-STARTING microphone detection...');
    _shouldBeListening = true;
    await startListening();
    debugPrint('✅ Microphone detection ACTIVE');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isListening) {
        _shouldBeListening = true; // Remember we were listening
        _stopListening();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldBeListening) {
        startListening();
      }
    }
  }

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  void toggleListening() {
    if (_isListening) {
      _shouldBeListening = false;
      _stopListening();
    } else {
      _shouldBeListening = true;
      startListening();
    }
  }

  Future<void> startListening() async {
    await _classifier.start();
    // await _transcriptionService.startListening(); // Disabled to prevent mic conflict with classifier
    _isListening = true;
    notifyListeners();

    // Subscribe to streams
    _detectionSubscription = _classifier.detectionStream.listen((results) {
      if (results.isNotEmpty) {
        // Take the top result
        final top = results.first;
        
        // Log what we're getting
        debugPrint('📢 SOUND PROVIDER RECEIVED: ${top.label} (${(top.boostedConfidence * 100).toStringAsFixed(1)}%)');
        
        // ALWAYS trigger alert for ALL detected sounds (no threshold filtering)
        // This ensures immediate feedback for deaf users
        _handlePriorityDetection(top);
      }
    });

    _amplitudeSubscription = _classifier.amplitudeStream.listen((amp) {
      _currentAmplitude = amp;
      // notifyListeners(); - Handled by visualizer stream more frequently
    });
    
    _visualizerSubscription = _classifier.visualizerStream.listen((data) {
        _waveformData = data;
        notifyListeners();
    });

    _transcriptionSubscription = _transcriptionService.textStream.listen((text) {
        _transcription = text;
        notifyListeners();
    });
    
    // Baby cry detection is always enabled automatically
    await _babyCryClassifier.start();
    _babyCrySubscription = _babyCryClassifier.predictionStream.listen((prediction) {
      _handleBabyCryDetection(prediction);
    });
  }

  void _stopListening() async {
    await _classifier.stop();
    await _transcriptionService.stopListening();
    await _babyCryClassifier.stop();
    await _detectionSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    await _visualizerSubscription?.cancel();
    await _transcriptionSubscription?.cancel();
    await _babyCrySubscription?.cancel();
    _isListening = false;
    _currentAmplitude = 0.0;
    _waveformData = [];
    _transcription = "";
    notifyListeners();
  }

  void toggleFlashlight() {
    _settings?.toggleFlashlight();
    notifyListeners();
  }

  void toggleScreenAlerts() {
    _screenAlertsEnabled = !_screenAlertsEnabled;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void clearAlert() {
    _lastEvent = null;
    notifyListeners();
  }
  
  void clearBabyCryAlert() {
    _lastBabyCryDetection = null;
    notifyListeners();
  }
  
  void clearBabyCryHistory() {
    _babyCryHistory.clear();
    notifyListeners();
  }
  
  /// Baby cry detection is now always enabled automatically
  /// This method is kept for backward compatibility but does nothing
  @Deprecated('Baby cry detection is always active')
  void toggleBabyCryDetection() async {
    // Baby cry detection is always on - no action needed
    debugPrint('ℹ️ Baby cry detection is always active');
  }
  
  /// Simulate baby cry detection for testing
  void simulateBabyCry(int categoryId) {
    _babyCryClassifier.triggerMockDetection(categoryId);
  }



  void simulateEvent(String label) {
    // Create a simulated priority result for testing
    final prioritySound = PrioritySoundsDatabase.getByKeyword(label);
    final result = ClassificationResult(
      label,
      0.99,
      DateTime.now(),
      boostedConfidence: 0.99,
      yamnetIndex: prioritySound?.yamnetIndex ?? -1,
      isPriority: prioritySound != null,
      priority: prioritySound?.priority ?? SoundPriority.medium,
      severity: prioritySound?.severity ?? AlertSeverity.attention,
    );
    _handlePriorityDetection(result);
  }

  /// Handle detection with priority-based throttling
  void _handlePriorityDetection(ClassificationResult result) {
    // Reduced throttle for faster consecutive alerts
    final throttleDuration = result.priority != null 
        ? Duration(milliseconds: PrioritySoundsDatabase.getThrottleDuration(result.priority!).inMilliseconds ~/ 2)
        : const Duration(seconds: 1);
    
    // Throttle: don't trigger if same event happened recently
    if (_lastEvent != null && 
        _lastEvent!.label == result.label && 
        DateTime.now().difference(_lastEvent!.timestamp) < throttleDuration) {
      return;
    }
    
    // Log the alert trigger
    debugPrint('⚡ ALERT TRIGGERED: ${result.label} (${(result.boostedConfidence * 100).toStringAsFixed(1)}%)');

    // Determine event type from priority severity
    String type = 'info';
    if (result.severity == AlertSeverity.emergency) {
      type = 'emergency';
    } else if (result.severity == AlertSeverity.warning || result.severity == AlertSeverity.attention) {
      type = 'warning';
    }

    final event = SoundEvent(
      id: DateTime.now().toIso8601String(),
      label: result.label,
      confidence: result.boostedConfidence > 0 ? result.boostedConfidence : result.confidence,
      timestamp: DateTime.now(),
      type: type,
    );

    _lastEvent = event;
    _history.insert(0, event);
    notifyListeners();

    // Trigger Alerts based on priority severity
    _triggerAlertForSound(result);

    // Auto dismiss - faster for critical sounds
    final dismissDelay = result.priority == SoundPriority.critical 
        ? const Duration(seconds: 8)  // Critical stays longer
        : const Duration(seconds: 5);
        
    Future.delayed(dismissDelay, () {
      if (_lastEvent == event) {
        _lastEvent = null;
        notifyListeners();
      }
    });
  }

  /// Trigger appropriate alert based on sound type
  void _triggerAlertForSound(ClassificationResult result) {
    final alertService = AlertService();
    final lower = result.label.toLowerCase();
    final intensity = _settings?.vibrationIntensity ?? VibrationIntensity.high;
    
    // EMERGENCY SOUNDS
    if (lower.contains('fire') || lower.contains('smoke') || lower.contains('siren') || 
        lower.contains('alarm') || lower.contains('police') || lower.contains('ambulance')) {
        alertService.triggerFireAlarm(withFlash: flashlightEnabled, intensity: intensity);
    } 
    // SECURITY SOUNDS
    else if (lower.contains('glass') || lower.contains('break') || lower.contains('shatter') || 
             lower.contains('smash') || lower.contains('crash')) {
        alertService.triggerGlassBreaking(withFlash: flashlightEnabled, intensity: intensity);
    } 
    else if (lower.contains('gunshot') || lower.contains('explosion') || lower.contains('blast')) {
        alertService.triggerExplosion(withFlash: flashlightEnabled, intensity: intensity);
    }
    // VEHICLE SOUNDS
    else if (lower.contains('horn') || lower.contains('vehicle') || lower.contains('honk') || 
             lower.contains('car') || lower.contains('truck') || lower.contains('train')) {
        alertService.triggerVehicleHorn(withFlash: flashlightEnabled, intensity: intensity);
    } 
    // DOOR/BELL SOUNDS
    else if (lower.contains('knock') || lower.contains('door')) {
        alertService.triggerDoorKnock(withFlash: flashlightEnabled, intensity: intensity);
    } 
    else if (lower.contains('doorbell') || lower.contains('ding') || lower.contains('bell')) {
        alertService.triggerDoorbell(withFlash: flashlightEnabled, intensity: intensity);
    }
    // BABY/HUMAN SOUNDS
    else if (lower.contains('baby') || lower.contains('cry') || lower.contains('infant')) {
        alertService.triggerBabyCry(withFlash: flashlightEnabled, intensity: intensity);
    } 
    else if (lower.contains('scream') || lower.contains('shout') || lower.contains('yell')) {
        alertService.triggerHumanDistress(withFlash: flashlightEnabled, intensity: intensity);
    }
    // PHONE
    else if (lower.contains('phone') || lower.contains('telephone') || lower.contains('ringtone') || lower.contains('ring')) {
        alertService.triggerPhoneRing(withFlash: flashlightEnabled, intensity: intensity);
    }
    // DANGEROUS ANIMALS
    else if (lower.contains('snake') || lower.contains('rattle')) {
        alertService.triggerDangerousAnimal(withFlash: flashlightEnabled, animalName: 'Snake', intensity: intensity);
    }
    else if (lower.contains('wolf') || lower.contains('lion') || lower.contains('tiger') || lower.contains('roar')) {
        alertService.triggerDangerousAnimal(withFlash: flashlightEnabled, animalName: 'Wild Animal', intensity: intensity);
    }
    // DOG SOUNDS
    else if (lower.contains('bark') || lower.contains('dog') || lower.contains('growl') || lower.contains('howl')) {
        alertService.triggerDogBark(withFlash: flashlightEnabled, intensity: intensity);
    }
    // OTHER ANIMALS
    else if (lower.contains('cat') || lower.contains('meow') || lower.contains('hiss')) {
        alertService.triggerAnimalAlert(withFlash: flashlightEnabled, animalName: 'Cat', intensity: intensity);
    }
    else if (lower.contains('horse') || lower.contains('neigh')) {
        alertService.triggerAnimalAlert(withFlash: flashlightEnabled, animalName: 'Horse', intensity: intensity);
    }
    else if (lower.contains('cow') || lower.contains('moo') || lower.contains('cattle')) {
        alertService.triggerAnimalAlert(withFlash: flashlightEnabled, animalName: 'Cow', intensity: intensity);
    }
    else if (lower.contains('bird') || lower.contains('chirp') || lower.contains('crow') || lower.contains('owl')) {
        alertService.triggerAnimalAlert(withFlash: flashlightEnabled, animalName: 'Bird', intensity: intensity);
    }
    else if (lower.contains('chicken') || lower.contains('rooster')) {
        alertService.triggerAnimalAlert(withFlash: flashlightEnabled, animalName: 'Rooster', intensity: intensity);
    }
    else if (lower.contains('bee') || lower.contains('wasp') || lower.contains('buzz')) {
        alertService.triggerAnimalAlert(withFlash: flashlightEnabled, animalName: 'Bee/Wasp', intensity: intensity);
    }
    else if (lower.contains('frog') || lower.contains('croak')) {
        alertService.triggerAnimalAlert(withFlash: flashlightEnabled, animalName: 'Frog', intensity: intensity);
    }
    // GENERIC - always vibrate for deaf users
    else {
        alertService.triggerGenericInfo(withFlash: flashlightEnabled, intensity: intensity);
    }
  }


  
  /// Handle baby cry detection with specialized alerts
  void _handleBabyCryDetection(BabyCryPrediction prediction) {
    debugPrint('👶 Baby Cry Detected: ${prediction.label} (${(prediction.confidence * 100).toStringAsFixed(1)}%)');
    
    // Update detection state
    _lastBabyCryDetection = prediction;
    _babyCryHistory.insert(0, prediction);
    
    // Keep history limited to last 10 detections
    if (_babyCryHistory.length > 10) {
      _babyCryHistory = _babyCryHistory.take(10).toList();
    }
    
    notifyListeners();
    
    // Trigger specialized alert based on priority
    final alertService = AlertService();
    
    if (prediction.isHighPriority) {
      // High priority: hungry, belly pain, temperature
      alertService.triggerCustomAlert(
        message: prediction.message,
        vibrationPattern: prediction.vibrationPattern,
        withFlash: flashlightEnabled,
        intensity: _settings?.vibrationIntensity ?? VibrationIntensity.high,
      );
    } else if (prediction.isMediumPriority) {
      // Medium priority: discomfort, tired, burping
      alertService.triggerCustomAlert(
        message: prediction.message,
        vibrationPattern: prediction.vibrationPattern,
        withFlash: flashlightEnabled,
        intensity: _settings?.vibrationIntensity ?? VibrationIntensity.high,
      );
    } else {
      // Low priority: silence (usually won't trigger)
      alertService.triggerCustomAlert(
        message: prediction.message,
        vibrationPattern: prediction.vibrationPattern,
        withFlash: false,
        intensity: _settings?.vibrationIntensity ?? VibrationIntensity.high,
      );
    }
    
    // Auto-dismiss after delay based on priority
    final dismissDelay = prediction.isHighPriority
        ? const Duration(seconds: 10)
        : const Duration(seconds: 5);
    
    Future.delayed(dismissDelay, () {
      if (_lastBabyCryDetection == prediction) {
        _lastBabyCryDetection = null;
        notifyListeners();
      }
    });
  }
}
