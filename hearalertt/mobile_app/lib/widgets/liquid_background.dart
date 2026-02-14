import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/theme/app_theme.dart';

/// Premium Liquid Background with animated organic blobs
/// 
/// Optimized for performance with controlled animation complexity
class LiquidBackground extends StatelessWidget {
  final bool subtle;
  
  const LiquidBackground({super.key, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final blobOpacity = subtle ? 0.25 : 0.4;
    
    return Container(
      color: AppTheme.void_,
      child: Stack(
        children: [
          // Base gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.void_,
                    AppTheme.surface.withOpacity(0.8),
                    AppTheme.void_,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // Blob 1: Primary Violet (Top-left)
          Positioned(
            top: -size.height * 0.12,
            left: -size.width * 0.2,
            child: _GlowBlob(
              color: AppTheme.primary,
              size: size.width * 0.8,
              opacity: blobOpacity,
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .move(
                begin: const Offset(0, 0),
                end: const Offset(30, 60),
                duration: 8.seconds,
                curve: Curves.easeInOutSine,
              )
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.15, 1.1),
                duration: 10.seconds,
              ),
          ),
          
          // Blob 2: Secondary Cyan (Bottom-right)
          Positioned(
            bottom: -size.height * 0.08,
            right: -size.width * 0.25,
            child: _GlowBlob(
              color: AppTheme.secondary,
              size: size.width * 0.7,
              opacity: blobOpacity * 0.8,
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .move(
                begin: const Offset(0, 0),
                end: const Offset(-40, -30),
                duration: 9.seconds,
                curve: Curves.easeInOutQuad,
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.1, 1.15),
                duration: 11.seconds,
              ),
          ),
          
          // Blob 3: Accent Pink (Center floating)
          if (!subtle)
            Positioned(
              top: size.height * 0.35,
              left: size.width * 0.1,
              child: _GlowBlob(
                color: AppTheme.accentPink,
                size: size.width * 0.5,
                opacity: blobOpacity * 0.6,
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                .move(
                  begin: const Offset(0, 0),
                  end: const Offset(50, 40),
                  duration: 12.seconds,
                  curve: Curves.easeInOutCubic,
                )
                .fadeIn(duration: 3.seconds),
            ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowBlob({
    required this.color,
    required this.size,
    this.opacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: size * 0.4,
            spreadRadius: size * 0.05,
          ),
          BoxShadow(
            color: color.withOpacity(opacity * 0.5),
            blurRadius: size * 0.6,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(opacity * 0.8),
                  color.withOpacity(opacity * 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
