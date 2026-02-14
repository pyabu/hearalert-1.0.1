import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:mobile_app/widgets/glass_container.dart';
import 'package:timeago/timeago.dart' as timeago;

class SoundMonitorCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDetected;
  final DateTime? lastDetected;

  const SoundMonitorCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDetected,
    this.lastDetected,
  });

  @override
  Widget build(BuildContext context) {
    return TectonicGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      border: isDetected 
          ? Border.all(color: color, width: 2)
          : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with Pulse Effect if detected
          Stack(
            alignment: Alignment.center,
            children: [
              if (isDetected)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat()).scale(
                  begin: const Offset(1, 1), 
                  end: const Offset(1.5, 1.5), 
                  duration: 1.seconds,
                ).fadeOut(duration: 1.seconds),
              
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDetected ? color : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: isDetected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 20)] : [],
                ),
                child: Icon(
                  icon,
                  color: isDetected ? Colors.white : color,
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Status / Time
          if (isDetected)
            Text(
              "DETECTED NOW",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 1,
              ),
            ).animate().fadeIn(duration: 200.ms)
          else if (lastDetected != null)
             Text(
              "Last: ${timeago.format(lastDetected!, locale: 'en_short')}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            )
          else
            Text(
              "Monitoring",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.3),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
