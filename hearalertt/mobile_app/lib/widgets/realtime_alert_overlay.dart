import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/config/realtime_alert_config.dart';

/// Full-screen alert overlay for real-time sound detection
class RealtimeAlertOverlay extends StatefulWidget {
  final String soundId;
  final String label;
  final double confidence;
  final VoidCallback onDismiss;
  final bool showFlash;

  const RealtimeAlertOverlay({
    super.key,
    required this.soundId,
    required this.label,
    required this.confidence,
    required this.onDismiss,
    this.showFlash = true,
  });

  @override
  State<RealtimeAlertOverlay> createState() => _RealtimeAlertOverlayState();
}

class _RealtimeAlertOverlayState extends State<RealtimeAlertOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  SoundAlertConfig? _alertConfig;
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    
    // Get alert configuration
    _alertConfig = RealtimeAlertDatabase.getAlertByLabel(widget.label) ??
        RealtimeAlertDatabase.getAlert(widget.soundId);
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    
    // Trigger vibration
    _triggerVibration();
    
    // Flash effect for critical alerts
    if (widget.showFlash && _alertConfig?.priority == AlertPriority.critical) {
      _startFlashing();
    }
  }
  
  void _triggerVibration() async {
    if (_alertConfig != null) {
      await _alertConfig!.triggerVibration();
    } else {
      await HapticFeedback.mediumImpact();
    }
  }
  
  void _startFlashing() async {
    for (int i = 0; i < 6 && mounted; i++) {
      setState(() => _flashing = !_flashing);
      await Future.delayed(const Duration(milliseconds: 150));
    }
    if (mounted) {
      setState(() => _flashing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertConfig = _alertConfig;
    final color = alertConfig != null 
        ? Color(alertConfig.colorHex) 
        : Colors.orange;
    final icon = alertConfig?.icon ?? '🔊';
    final message = alertConfig?.alertMessage ?? 'Sound Detected: ${widget.label}';
    final shortMessage = alertConfig?.shortMessage ?? widget.label;
    final priority = alertConfig?.priority ?? AlertPriority.medium;
    
    // Determine background color based on priority
    Color backgroundColor;
    switch (priority) {
      case AlertPriority.critical:
        backgroundColor = _flashing ? Colors.yellow : Colors.red;
        break;
      case AlertPriority.high:
        backgroundColor = Colors.orange;
        break;
      case AlertPriority.medium:
        backgroundColor = Colors.blue;
        break;
      case AlertPriority.low:
        backgroundColor = Colors.green;
        break;
      case AlertPriority.info:
        backgroundColor = Colors.grey;
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: backgroundColor.withOpacity(0.95),
              child: InkWell(
                onTap: widget.onDismiss,
                child: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Text(
                          icon,
                          style: const TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 24),
                        
                        // Main Alert Message
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Sound Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            shortMessage.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Confidence indicator
                        Text(
                          '${(widget.confidence * 100).toStringAsFixed(0)}% confidence',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Timestamp
                        Text(
                          'Detected at ${TimeOfDay.now().format(context)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Dismiss button
                        OutlinedButton.icon(
                          onPressed: widget.onDismiss,
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text(
                            'TAP TO DISMISS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Description
                        if (alertConfig?.description != null)
                          Text(
                            alertConfig!.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact alert banner for non-critical sounds
class RealtimeAlertBanner extends StatelessWidget {
  final String soundId;
  final String label;
  final double confidence;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const RealtimeAlertBanner({
    super.key,
    required this.soundId,
    required this.label,
    required this.confidence,
    required this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final alertConfig = RealtimeAlertDatabase.getAlertByLabel(label) ??
        RealtimeAlertDatabase.getAlert(soundId);
    
    final color = alertConfig != null 
        ? Color(alertConfig.colorHex) 
        : Colors.orange;
    final icon = alertConfig?.icon ?? '🔊';
    final message = alertConfig?.shortMessage ?? label;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap ?? onDismiss,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(confidence * 100).toStringAsFixed(0)}% confidence',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Dismiss button
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(Icons.close, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
