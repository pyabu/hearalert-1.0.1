import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// HearAlert Custom Model Classifier
/// Uses the trained model for enhanced detection of:
/// - Baby crying (multiple types: hungry, tired, discomfort, etc.)
/// - Dog barking
/// - Cat meowing  
/// - Door knock
/// - Glass breaking
/// - Emergency siren
/// - Fire alarm

class HearAlertCategory {
  final String id;
  final String displayName;
  final int priority;
  final String alertType;
  final String color;
  final List<int> vibrationPattern;

  const HearAlertCategory({
    required this.id,
    required this.displayName,
    required this.priority,
    required this.alertType,
    required this.color,
    this.vibrationPattern = const [0, 200, 100, 200],
  });
}

/// Trained categories mapping - Deaf Accessibility Focus
class HearAlertCategories {
  static const Map<String, HearAlertCategory> categories = {
    // ═══════════════════════════════════════════════════════════════════
    // CRITICAL - Emergency & Safety
    // ═══════════════════════════════════════════════════════════════════
    'baby_cry': HearAlertCategory(
      id: 'baby_cry',
      displayName: 'Baby Crying',
      priority: 10,
      alertType: 'critical',
      color: '#FF6B9D',
      vibrationPattern: [0, 500, 200, 500, 200, 500],
    ),
    'car_horn': HearAlertCategory(
      id: 'car_horn',
      displayName: 'Car Horn',
      priority: 10,
      alertType: 'critical',
      color: '#FFD700',
      vibrationPattern: [0, 300, 100, 300, 100, 300, 100, 300],
    ),
    'siren': HearAlertCategory(
      id: 'siren',
      displayName: 'Emergency Siren',
      priority: 10,
      alertType: 'critical',
      color: '#FF0000',
      vibrationPattern: [0, 1000, 500, 1000],
    ),
    'fire_alarm': HearAlertCategory(
      id: 'fire_alarm',
      displayName: 'Fire Alarm',
      priority: 10,
      alertType: 'critical',
      color: '#FF4500',
      vibrationPattern: [0, 500, 100, 500, 100, 500, 100, 500],
    ),
    'glass_breaking': HearAlertCategory(
      id: 'glass_breaking',
      displayName: 'Glass Breaking',
      priority: 9,
      alertType: 'critical',
      color: '#FF6B6B',
      vibrationPattern: [0, 500, 100, 500, 100, 500],
    ),
    'train': HearAlertCategory(
      id: 'train',
      displayName: 'Train',
      priority: 9,
      alertType: 'critical',
      color: '#8B4513',
      vibrationPattern: [0, 800, 200, 800],
    ),
    
    // ═══════════════════════════════════════════════════════════════════
    // HIGH PRIORITY - Traffic & Home Alerts
    // ═══════════════════════════════════════════════════════════════════
    'traffic': HearAlertCategory(
      id: 'traffic',
      displayName: 'Traffic/Vehicle',
      priority: 8,
      alertType: 'high',
      color: '#FFA500',
      vibrationPattern: [0, 400, 150, 400],
    ),
    'door_knock': HearAlertCategory(
      id: 'door_knock',
      displayName: 'Door Knock',
      priority: 8,
      alertType: 'high',
      color: '#8B4513',
      vibrationPattern: [0, 200, 100, 200, 100, 200],
    ),
    'doorbell': HearAlertCategory(
      id: 'doorbell',
      displayName: 'Doorbell',
      priority: 8,
      alertType: 'high',
      color: '#4169E1',
      vibrationPattern: [0, 300, 150, 300],
    ),
    'phone_ring': HearAlertCategory(
      id: 'phone_ring',
      displayName: 'Phone/Alarm Ring',
      priority: 7,
      alertType: 'high',
      color: '#32CD32',
      vibrationPattern: [0, 200, 100, 200, 100, 200, 100, 200],
    ),
    'dog_bark': HearAlertCategory(
      id: 'dog_bark',
      displayName: 'Dog Barking',
      priority: 7,
      alertType: 'high',
      color: '#D4A373',
      vibrationPattern: [0, 300, 100, 300, 100, 300],
    ),
    'thunderstorm': HearAlertCategory(
      id: 'thunderstorm',
      displayName: 'Thunderstorm',
      priority: 7,
      alertType: 'high',
      color: '#4B0082',
      vibrationPattern: [0, 600, 200, 400],
    ),
    
    // ═══════════════════════════════════════════════════════════════════
    // MEDIUM PRIORITY - Awareness
    // ═══════════════════════════════════════════════════════════════════
    'helicopter': HearAlertCategory(
      id: 'helicopter',
      displayName: 'Helicopter',
      priority: 6,
      alertType: 'medium',
      color: '#708090',
      vibrationPattern: [0, 400, 100, 400],
    ),
    'cat_meow': HearAlertCategory(
      id: 'cat_meow',
      displayName: 'Cat Meowing',
      priority: 5,
      alertType: 'medium',
      color: '#4ECDC4',
      vibrationPattern: [0, 200, 100, 200],
    ),
  };

  static HearAlertCategory? getCategory(String id) => categories[id];
}

class HearAlertResult {
  final String categoryId;
  final String displayName;
  final double confidence;
  final DateTime timestamp;
  final int priority;
  final String alertType;
  final String color;
  final List<int> vibrationPattern;

  HearAlertResult({
    required this.categoryId,
    required this.displayName,
    required this.confidence,
    required this.timestamp,
    required this.priority,
    required this.alertType,
    required this.color,
    this.vibrationPattern = const [],
  });

  bool get isCritical => alertType == 'critical';
  bool get isHigh => alertType == 'high' || isCritical;

  @override
  String toString() => '$displayName (${(confidence * 100).toStringAsFixed(1)}%)';
}

/// HearAlert Custom Model Classifier Service
/// This service runs alongside YAMNet for enhanced accuracy
class HearAlertClassifierService {
  static final HearAlertClassifierService _instance = HearAlertClassifierService._internal();
  factory HearAlertClassifierService() => _instance;
  HearAlertClassifierService._internal();

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;

  final StreamController<List<HearAlertResult>> _resultController = StreamController.broadcast();
  Stream<List<HearAlertResult>> get detectionStream => _resultController.stream;

  // Model configuration
  static const String _modelPath = 'assets/models/hearalert_classifier.tflite';
  static const String _labelsPath = 'assets/models/hearalert_labels.txt';
  static const double _minConfidenceThreshold = 0.35;
  static const double _criticalThreshold = 0.60;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      log('🎯 Initializing HearAlert Custom Classifier...');

      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        log('Skipping HearAlert model initialization on Desktop (mock mode).');
        _isInitialized = true;
        return;
      }

      // Load custom trained model
      final options = InterpreterOptions()..threads = 2;
      
      try {
        _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
        log('✓ HearAlert model loaded successfully.');
      } catch (e) {
        log('⚠️ Could not load HearAlert model: $e');
        log('Falling back to YAMNet-only mode.');
        return;
      }

      if (_interpreter != null) {
        _interpreter!.allocateTensors();
        final inputTensor = _interpreter!.getInputTensor(0);
        final outputTensor = _interpreter!.getOutputTensor(0);
        log('  Input shape: ${inputTensor.shape}');
        log('  Output shape: ${outputTensor.shape}');
      }

      // Load labels
      try {
        final labelData = await rootBundle.loadString(_labelsPath);
        _labels = labelData.split('\n').where((l) => l.trim().isNotEmpty).toList();
        log('✓ Labels loaded: ${_labels?.length} categories');
        log('  Categories: ${_labels?.join(", ")}');
      } catch (e) {
        log('⚠️ Could not load labels: $e');
        // Use default labels
        _labels = ['baby_cry', 'dog_bark', 'cat_meow', 'door_knock', 'glass_breaking', 'siren', 'fire_alarm'];
      }

      _isInitialized = true;
      log('🎯 HearAlert Classifier initialized successfully!');

    } catch (e) {
      log('Error initializing HearAlert Classifier: $e');
    }
  }

  /// Process YAMNet embeddings through HearAlert model
  /// The HearAlert model was trained on YAMNet embeddings (1024-dimensional)
  Future<List<HearAlertResult>> classifyEmbeddings(List<double> yamnetEmbeddings) async {
    if (_interpreter == null || _labels == null) {
      return [];
    }

    try {
      // Input: YAMNet embeddings [1024]
      var input = Float32List.fromList(yamnetEmbeddings).reshape([1, 1024]);
      
      // Output: Category probabilities
      int numClasses = _labels!.length;
      var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);
      
      _interpreter!.run(input, output);
      
      final List<double> scores = output[0];
      return _getTopResults(scores);

    } catch (e) {
      log('HearAlert inference error: $e');
      return [];
    }
  }

  List<HearAlertResult> _getTopResults(List<double> scores) {
    if (_labels == null) return [];

    final results = <HearAlertResult>[];
    
    for (int i = 0; i < scores.length && i < _labels!.length; i++) {
      final score = scores[i];
      final categoryId = _labels![i];
      final category = HearAlertCategories.getCategory(categoryId);
      
      if (category != null && score >= _minConfidenceThreshold) {
        results.add(HearAlertResult(
          categoryId: categoryId,
          displayName: category.displayName,
          confidence: score,
          timestamp: DateTime.now(),
          priority: category.priority,
          alertType: category.alertType,
          color: category.color,
          vibrationPattern: category.vibrationPattern,
        ));
      }
    }

    // Sort by priority first, then by confidence
    results.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return b.confidence.compareTo(a.confidence);
    });

    if (results.isNotEmpty) {
      final top = results.first;
      log('🎯 HEARALERT: ${top.displayName} (${(top.confidence * 100).toStringAsFixed(1)}%)');
      _resultController.add(results);
    }

    return results.take(3).toList();
  }

  /// Check if a result should trigger an immediate alert
  bool shouldTriggerAlert(HearAlertResult result) {
    return result.confidence >= _criticalThreshold && result.isCritical;
  }

  void dispose() {
    _interpreter?.close();
    _resultController.close();
    _isInitialized = false;
  }
}

/// Configuration for real-time detection
class HearAlertConfig {
  static const Map<String, dynamic> realTimeConfig = {
    'audio_format': {
      'sample_rate': 16000,
      'channels': 1,
      'bit_depth': 16,
    },
    'detection': {
      'buffer_size_ms': 1000,
      'overlap_ms': 500,
      'min_confidence': 0.35,
      'critical_confidence': 0.60,
    },
    'alerts': {
      'enabled': true,
      'vibration': true,
      'visual_flash': true,
      'sound': false, // Disabled for deaf users
    },
  };

  static const List<String> priorityCategories = [
    'baby_cry',
    'fire_alarm',
    'siren',
    'glass_breaking',
    'door_knock',
    'dog_bark',
    'cat_meow',
  ];
}
