// Baby Cry Detection Models

class BabyCryPrediction {
  final int categoryId;
  final String categoryName;
  final String label;
  final String icon;
  final String message;
  final double confidence;
  final String priority;
  final List<int> vibrationPattern;
  final String flashlightPattern;
  final DateTime timestamp;

  BabyCryPrediction({
    required this.categoryId,
    required this.categoryName,
    required this.label,
    required this.icon,
    required this.message,
    required this.confidence,
    required this.priority,
    required this.vibrationPattern,
    required this.flashlightPattern,
    required this.timestamp,
  });

  bool get isHighPriority => priority == 'high';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';

  @override
  String toString() => '$label ($categoryName) - ${(confidence * 100).toStringAsFixed(1)}%';
}

class BabyCryDetectionState {
  final bool isEnabled;
  final bool isListening;
  final BabyCryPrediction? lastDetection;
  final List<BabyCryPrediction> recentHistory;
  final int detectionCount;

  BabyCryDetectionState({
    this.isEnabled = true,
    this.isListening = false,
    this.lastDetection,
    this.recentHistory = const [],
    this.detectionCount = 0,
  });

  BabyCryDetectionState copyWith({
    bool? isEnabled,
    bool? isListening,
    BabyCryPrediction? lastDetection,
    List<BabyCryPrediction>? recentHistory,
    int? detectionCount,
  }) {
    return BabyCryDetectionState(
      isEnabled: isEnabled ?? this.isEnabled,
      isListening: isListening ?? this.isListening,
      lastDetection: lastDetection ?? this.lastDetection,
      recentHistory: recentHistory ?? this.recentHistory,
      detectionCount: detectionCount ?? this.detectionCount,
    );
  }
}
