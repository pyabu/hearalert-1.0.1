import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Stack(
      children: [
        // Top Left Blob (Blue/Cyber)
        Positioned(
          top: -h * 0.15,
          left: -w * 0.2,
          child: Container(
            width: w * 0.9, // Responsive width
            height: w * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryNeon.withOpacity(0.3),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 4.seconds)
          .move(begin: const Offset(0, 0), end: Offset(w * 0.1, h * 0.05), duration: 5.seconds),
        ),

        // Bottom Right Blob (Purple)
        Positioned(
          bottom: -h * 0.1,
          right: -w * 0.2,
          child: Container(
            width: w * 0.8,
            height: w * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryNeon.withOpacity(0.3),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 6.seconds)
          .move(begin: const Offset(0, 0), end: Offset(-w * 0.1, -h * 0.05), duration: 7.seconds),
        ),

        // Center/Random Blob
          Positioned(
          top: h * 0.4,
          left: w * 0.2,
          child: Container(
            width: w * 0.5,
            height: w * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.tectonicBlue.withOpacity(0.15),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fadeIn(duration: 3.seconds)
          .move(begin: const Offset(0, 0), end: Offset(w * 0.2, -h * 0.03), duration: 8.seconds),
        ),

        // Blur Filter to diffuse everything
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
