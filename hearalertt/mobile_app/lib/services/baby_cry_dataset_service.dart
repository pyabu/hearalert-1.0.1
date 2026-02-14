import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

/// Baby cry detection category model
class BabyCryCategory {
  final int id;
  final String name;
  final String label;
  final String icon;
  final String priority;
  final String message;
  final List<int> vibrationPattern;
  final String flashlightPattern;

  BabyCryCategory({
    required this.id,
    required this.name,
    required this.label,
    required this.icon,
    required this.priority,
    required this.message,
    required this.vibrationPattern,
    required this.flashlightPattern,
  });

  factory BabyCryCategory.fromMap(Map<dynamic, dynamic> map) {
    return BabyCryCategory(
      id: map['id'] as int,
      name: map['name'] as String,
      label: map['label'] as String,
      icon: map['icon'] as String,
      priority: map['priority'] as String,
      message: map['message'] as String,
      vibrationPattern: (map['vibration'] as List<dynamic>).cast<int>(),
      flashlightPattern: map['flashlight'] as String,
    );
  }

  bool get isHighPriority => priority == 'high';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';
}

/// Audio configuration for baby cry detection
class AudioConfig {
  final int sampleRate;
  final int bufferDurationMs;
  final int minDetectionIntervalMs;
  final int nMels;
  final int nFft;
  final int hopLength;

  AudioConfig({
    required this.sampleRate,
    required this.bufferDurationMs,
    required this.minDetectionIntervalMs,
    required this.nMels,
    required this.nFft,
    required this.hopLength,
  });

  factory AudioConfig.fromMap(Map<dynamic, dynamic> map) {
    return AudioConfig(
      sampleRate: map['sample_rate'] as int,
      bufferDurationMs: map['buffer_duration_ms'] as int,
      minDetectionIntervalMs: map['min_detection_interval_ms'] as int,
      nMels: map['n_mels'] as int,
      nFft: map['n_fft'] as int,
      hopLength: map['hop_length'] as int,
    );
  }
}

/// Model information for baby cry detection
class ModelInfo {
  final String format;
  final List<int> inputShape;
  final int outputClasses;
  final double inferenceThreshold;

  ModelInfo({
    required this.format,
    required this.inputShape,
    required this.outputClasses,
    required this.inferenceThreshold,
  });

  factory ModelInfo.fromMap(Map<dynamic, dynamic> map) {
    return ModelInfo(
      format: map['format'] as String,
      inputShape: (map['input_shape'] as List<dynamic>).cast<int>(),
      outputClasses: map['output_classes'] as int,
      inferenceThreshold: (map['inference_threshold'] as num).toDouble(),
    );
  }
}

/// Main dataset manifest for baby cry detection
class BabyCryManifest {
  final String version;
  final ModelInfo modelInfo;
  final List<BabyCryCategory> categories;
  final AudioConfig audioConfig;

  BabyCryManifest({
    required this.version,
    required this.modelInfo,
    required this.categories,
    required this.audioConfig,
  });

  factory BabyCryManifest.fromMap(Map<dynamic, dynamic> map) {
    return BabyCryManifest(
      version: map['version'] as String,
      modelInfo: ModelInfo.fromMap(map['model_info']),
      categories: (map['categories'] as List<dynamic>)
          .map((c) => BabyCryCategory.fromMap(c))
          .toList(),
      audioConfig: AudioConfig.fromMap(map['audio_config']),
    );
  }

  /// Get category by ID
  BabyCryCategory? getCategoryById(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by name
  BabyCryCategory? getCategoryByName(String name) {
    try {
      return categories.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get all high priority categories
  List<BabyCryCategory> get highPriorityCategories {
    return categories.where((c) => c.isHighPriority).toList();
  }

  /// Get all medium priority categories
  List<BabyCryCategory> get mediumPriorityCategories {
    return categories.where((c) => c.isMediumPriority).toList();
  }

  /// Get all low priority categories
  List<BabyCryCategory> get lowPriorityCategories {
    return categories.where((c) => c.isLowPriority).toList();
  }
}

/// Service to load and manage baby cry dataset manifest
class BabyCryDatasetService {
  static BabyCryDatasetService? _instance;
  BabyCryManifest? _manifest;

  BabyCryDatasetService._();

  static BabyCryDatasetService get instance {
    _instance ??= BabyCryDatasetService._();
    return _instance!;
  }

  /// Load the manifest from assets
  Future<void> loadManifest() async {
    try {
      final String yamlString =
          await rootBundle.loadString('assets/baby_cry_manifest.yaml');
      final dynamic yamlData = loadYaml(yamlString);

      // Convert YamlMap to regular Map
      final Map<dynamic, dynamic> manifestMap = _yamlToMap(yamlData);

      _manifest = BabyCryManifest.fromMap(manifestMap);

      debugPrint('✅ Baby cry manifest loaded successfully');
      debugPrint('   Version: ${_manifest!.version}');
      debugPrint('   Categories: ${_manifest!.categories.length}');
      debugPrint('   Model format: ${_manifest!.modelInfo.format}');
    } catch (e) {
      debugPrint('⚠️ Baby cry manifest not found (optional feature): $e');
      // Don't rethrow - baby cry detection is an optional feature
      _manifest = null;
    }
  }

  /// Convert YamlMap to regular Map recursively
  dynamic _yamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final Map<dynamic, dynamic> map = {};
      yaml.forEach((key, value) {
        map[key] = _yamlToMap(value);
      });
      return map;
    } else if (yaml is YamlList) {
      return yaml.map((item) => _yamlToMap(item)).toList();
    } else {
      return yaml;
    }
  }

  /// Get the loaded manifest
  BabyCryManifest? get manifest => _manifest;

  /// Check if manifest is loaded
  bool get isLoaded => _manifest != null;

  /// Get category by prediction index
  BabyCryCategory? getCategoryByPrediction(int predictionIndex) {
    return _manifest?.getCategoryById(predictionIndex);
  }

  /// Get appropriate vibration pattern for a category
  List<int> getVibrationPattern(int categoryId) {
    final category = _manifest?.getCategoryById(categoryId);
    return category?.vibrationPattern ?? [0, 200]; // Default pattern
  }

  /// Get appropriate flashlight pattern for a category
  String getFlashlightPattern(int categoryId) {
    final category = _manifest?.getCategoryById(categoryId);
    return category?.flashlightPattern ?? 'none';
  }

  /// Get alert message for a category
  String getAlertMessage(int categoryId) {
    final category = _manifest?.getCategoryById(categoryId);
    return category?.message ?? 'Baby cry detected';
  }

  /// Get icon for a category
  String getCategoryIcon(int categoryId) {
    final category = _manifest?.getCategoryById(categoryId);
    return category?.icon ?? '🔔';
  }

  /// Check if category should trigger immediate alert
  bool shouldImmediatelyAlert(int categoryId) {
    final category = _manifest?.getCategoryById(categoryId);
    return category?.isHighPriority ?? false;
  }

  /// Get audio processing parameters
  AudioConfig? get audioConfig => _manifest?.audioConfig;

  /// Get model threshold for inference
  double get inferenceThreshold =>
      _manifest?.modelInfo.inferenceThreshold ?? 0.7;
}
