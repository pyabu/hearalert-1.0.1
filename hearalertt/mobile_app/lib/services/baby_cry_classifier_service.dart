import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:mobile_app/models/baby_cry_models.dart';
import 'package:mobile_app/services/baby_cry_dataset_service.dart';
import 'package:mobile_app/services/audio_classifier_service.dart'; // To get raw stream
import 'package:tflite_flutter/tflite_flutter.dart';

/// Baby Cry Classifier Service
/// 
/// Uses a custom TFLite model trained on the baby-cry dataset.
/// Falls back to mock detection if model is missing or on Desktop.
class BabyCryClassifierService {
  static final BabyCryClassifierService _instance = BabyCryClassifierService._internal();
  factory BabyCryClassifierService() => _instance;
  BabyCryClassifierService._internal();

  final BabyCryDatasetService _datasetService = BabyCryDatasetService.instance;
  
  final StreamController<BabyCryPrediction> _predictionController = StreamController.broadcast();
  Stream<BabyCryPrediction> get predictionStream => _predictionController.stream;

  bool _isInitialized = false;
  bool _isListening = false;
  bool get isListening => _isListening;

  // TFLite fields
  Interpreter? _interpreter;
  List<String> _labels = [];
  StreamSubscription? _audioSubscription;
  List<double> _audioBuffer = [];
  int _inputLength = 15600; // Default YAMNet length, will update from model
  bool _useMock = false;

  // Detection throttling
  DateTime? _lastDetection;
  static const Duration _minDetectionInterval = Duration(seconds: 3);

  // Mock detection randomizer
  final math.Random _random = math.Random();
  Timer? _mockDetectionTimer;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      log('Initializing BabyCryClassifierService...');
      
      // Load dataset manifest for metadata
      if (!_datasetService.isLoaded) {
        await _datasetService.loadManifest();
      }

      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        log('Using Mock Baby Cry Detection (Desktop)');
        _useMock = true;
      } else {
        // Try loading TFLite model with CPU optimization
        try {
          final options = InterpreterOptions()..threads = 4;
          _interpreter = await Interpreter.fromAsset('assets/models/baby_cry_model.tflite', options: options);
          _interpreter!.allocateTensors();
          final inputShape = _interpreter!.getInputTensor(0).shape;
          _inputLength = inputShape.isNotEmpty ? inputShape.reduce((a, b) => a * b) : 15600;
          log('✅ Baby Cry Model loaded. Input length: $_inputLength');

          // Load labels
          final labelData = await rootBundle.loadString('assets/models/baby_cry_labels.txt');
          _labels = labelData.split('\n').where((l) => l.trim().isNotEmpty).toList();
          log('Labels loaded: ${_labels.length}');

        } catch (e) {
          log('⚠️ Baby Cry Model not found or invalid ($e). Falling back to MOCK.');
          _useMock = true;
        }
      }

      _isInitialized = true;
      log('✅ BabyCryClassifierService initialized (Mock: $_useMock)');
    } catch (e) {
      log('❌ Error initializing BabyCryClassifierService: $e');
    }
  }

  /// Start listening for baby cries
  Future<void> start() async {
    if (_isListening) return;
    if (!_isInitialized) await initialize();

    // If dataset manifest failed to load, skip baby cry detection
    if (!_datasetService.isLoaded) {
      log('⚠️ Skipping baby cry detection (manifest not available)');
      return;
    }

    _isListening = true;
    log('🔊 Baby cry detection started');

    if (_useMock) {
      _startMockDetection();
    } else {
      _startRealDetection();
    }
  }

  /// Stop listening
  Future<void> stop() async {
    _isListening = false;
    _mockDetectionTimer?.cancel();
    _mockDetectionTimer = null;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    _audioBuffer.clear();
    log('⏸️ Baby cry detection stopped');
  }

  void _startRealDetection() {
    // Subscribe to raw audio from the main AudioClassifierService
    // This avoids seizing the microphone twice
    final mainService = AudioClassifierService();
    // Ensure main service is running (it handles mic permission)
    if (!mainService.isRecording) {
      mainService.start(); 
    }

    _audioSubscription = mainService.rawAudioStream.listen((samples) {
      _processAudioSamples(samples);
    });
  }

  void _processAudioSamples(List<int> rawSamples) {
    if (_interpreter == null) return;

    // Convert to float
    for (int i = 0; i < rawSamples.length; i += 2) {
      if (i + 1 >= rawSamples.length) break;
      int s1 = rawSamples[i];
      int s2 = rawSamples[i + 1];
      int s16 = (s2 << 8) | (s1 & 0xff);
      if ((s16 & 0x8000) != 0) s16 -= 0x10000;
      _audioBuffer.add(s16 / 32768.0);
    }

    // Inference when buffer full
    if (_audioBuffer.length >= _inputLength) {
      final chunk = _audioBuffer.sublist(0, _inputLength);
      // Overlap: keep last 50%
      final overlap = (_inputLength * 0.5).toInt();
      _audioBuffer = _audioBuffer.sublist(overlap);
      
      _runInference(chunk);
    }
  }

  Future<void> _runInference(List<double> inputChunk) async {
    try {
      // Input: [1, inputLength]
      var input = Float32List.fromList(inputChunk).reshape([1, _inputLength]);
      
      // Output: [1, numClasses]
      int outputClasses = _labels.length;
      if (outputClasses == 0) outputClasses = _interpreter!.getOutputTensor(0).shape.last;
      
      var output = List.filled(outputClasses, 0.0).reshape([1, outputClasses]);
      
      _interpreter!.run(input, output);
      
      // Process results
      final scores = output[0] as List<double>;
      _handleResults(scores);

    } catch (e) {
      log('Baby Cry Inference Error: $e');
    }
  }

  void _handleResults(List<double> scores) {
    // Find top score
    int topIndex = -1;
    double topScore = 0.0;
    
    for (int i = 0; i < scores.length; i++) {
        if (scores[i] > topScore) {
            topScore = scores[i];
            topIndex = i;
        }
    }

    if (topIndex == -1 || topIndex >= _labels.length) return;

    final label = _labels[topIndex];
    if (label == 'silence') return; // Ignore silence

    // Check threshold (config from dataset service)
    if (topScore >= _datasetService.inferenceThreshold) {
      // Map label to category ID (assuming label matches category name/label)
      // This requires the model labels to match dataset categories
      final category = _datasetService.manifest?.categories.firstWhere(
        (c) => c.name == label || c.label == label,
        orElse: () => _datasetService.manifest!.categories.first, // Fallback
      );

      if (category == null) return;
      
      _emitPrediction(category, topScore);
    }
  }

  /// Mock detection for testing (simulates baby cry detection)
  void _startMockDetection() {
    _mockDetectionTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }
      if (_random.nextDouble() < 0.3) {
        _simulateMockDetection();
      }
    });
  }

  void _simulateMockDetection() {
    if (_lastDetection != null && 
        DateTime.now().difference(_lastDetection!) < _minDetectionInterval) return;

    final categories = _datasetService.manifest?.categories ?? [];
    if (categories.isEmpty) return;

    final activeCat = categories.where((c) => c.name != 'silence').toList();
    if (activeCat.isEmpty) return;

    final category = activeCat[_random.nextInt(activeCat.length)];
    final confidence = 0.65 + (_random.nextDouble() * 0.3);

    _emitPrediction(category, confidence);
  }

  void _emitPrediction(BabyCryCategory category, double confidence) {
    // Throttle
     if (_lastDetection != null && 
        DateTime.now().difference(_lastDetection!) < _minDetectionInterval) return;

    _lastDetection = DateTime.now();

    final prediction = BabyCryPrediction(
      categoryId: category.id,
      categoryName: category.name,
      label: category.label,
      icon: category.icon,
      message: category.message,
      confidence: confidence,
      priority: category.priority,
      vibrationPattern: category.vibrationPattern,
      flashlightPattern: category.flashlightPattern,
      timestamp: DateTime.now(),
    );

    _predictionController.add(prediction);
    log('👶 BABY CRY DETECTED: ${prediction.label} (${(confidence * 100).toStringAsFixed(1)}%)');
  }

  /// Manually trigger detection (for testing UI)
  void triggerMockDetection(int categoryId) {
     if (!_isInitialized) return;
     final category = _datasetService.manifest?.getCategoryById(categoryId);
     if (category != null) _emitPrediction(category, 0.95);
  }

  void dispose() {
    stop();
    _predictionController.close();
    _interpreter?.close();
  }
}

