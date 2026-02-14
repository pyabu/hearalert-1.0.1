import 'package:flutter/material.dart';
import 'package:mobile_app/services/baby_cry_dataset_service.dart';

/// Example of how to integrate the Baby Cry Dataset Service
/// into your existing app for responsive real-time detection
class BabyCryIntegrationExample extends StatefulWidget {
  const BabyCryIntegrationExample({super.key});

  @override
  State<BabyCryIntegrationExample> createState() =>
      _BabyCryIntegrationExampleState();
}

class _BabyCryIntegrationExampleState
    extends State<BabyCryIntegrationExample> {
  final BabyCryDatasetService _datasetService =
      BabyCryDatasetService.instance;
  bool _isLoaded = false;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _loadDataset();
  }

  Future<void> _loadDataset() async {
    try {
      await _datasetService.loadManifest();
      setState(() {
        _isLoaded = true;
        _status = 'Dataset loaded successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading dataset: $e';
      });
    }
  }

  /// Simulate a prediction and show responsive alert
  void _simulatePrediction(int categoryId) {
    if (!_isLoaded) return;

    final category = _datasetService.manifest?.getCategoryById(categoryId);
    if (category == null) return;

    // Get responsive alert configuration
    final vibrationPattern = _datasetService.getVibrationPattern(categoryId);
    final flashlightPattern = _datasetService.getFlashlightPattern(categoryId);
    final message = _datasetService.getAlertMessage(categoryId);
    final icon = _datasetService.getCategoryIcon(categoryId);
    final shouldAlert = _datasetService.shouldImmediatelyAlert(categoryId);

    // Show responsive alert dialog
    showDialog(
      context: context,
      barrierDismissible: !shouldAlert,
      builder: (context) => AlertDialog(
        backgroundColor: category.isHighPriority
            ? Colors.red.shade900.withOpacity(0.95)
            : category.isMediumPriority
                ? Colors.orange.shade900.withOpacity(0.95)
                : Colors.blue.shade900.withOpacity(0.95),
        title: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Priority: ${category.priority.toUpperCase()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vibration: ${vibrationPattern.join(", ")}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              'Flashlight: $flashlightPattern',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Dismiss',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // In real implementation, you would trigger:
    // - Vibration.vibrate(pattern: vibrationPattern)
    // - TorchLight control based on flashlightPattern
    // - Screen flash animation
    debugPrint('🔔 Alert triggered for: ${category.label}');
    debugPrint('   Vibration pattern: $vibrationPattern');
    debugPrint('   Flashlight: $flashlightPattern');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Cry Detection'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade900,
      body: !_isLoaded
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    _status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Status card
                Card(
                  color: Colors.grey.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✅ Dataset Ready',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version: ${_datasetService.manifest?.version}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Categories: ${_datasetService.manifest?.categories.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Model: ${_datasetService.manifest?.modelInfo.format}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Threshold: ${_datasetService.inferenceThreshold}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Categories
                const Text(
                  'Test Detection Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Category buttons
                ...(_datasetService.manifest?.categories ?? []).map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _simulatePrediction(category.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: category.isHighPriority
                            ? Colors.red.shade700
                            : category.isMediumPriority
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Row(
                        children: [
                          Text(
                            category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  category.priority.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
