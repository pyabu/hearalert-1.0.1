import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/theme/app_theme.dart';

/// Animated Aurora Background with floating orbs
class AuroraBackground extends StatelessWidget {
  final bool animate;
  final double intensity;
  
  const AuroraBackground({
    super.key, 
    this.animate = true,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return SizedBox.expand(
      child: Stack(
        children: [
          // Base Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.surfaceGradient,
            ),
          ),
          
          // Aurora Orbs
          _AuroraOrb(
            size: size.width * 0.8,
            color: AppTheme.primary,
            top: -size.height * 0.15,
            right: -size.width * 0.3,
            animate: animate,
            delay: 0,
          ),
          _AuroraOrb(
            size: size.width * 0.6,
            color: AppTheme.secondary,
            bottom: size.height * 0.1,
            left: -size.width * 0.25,
            animate: animate,
            delay: 1000,
          ),
          _AuroraOrb(
            size: size.width * 0.5,
            color: AppTheme.tertiary,
            top: size.height * 0.4,
            right: -size.width * 0.15,
            animate: animate,
            delay: 2000,
          ),
          
          // Noise Overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  AppTheme.void_.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool animate;
  final int delay;

  const _AuroraOrb({
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.animate = true,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget orb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );

    if (animate) {
      orb = orb
        .animate(onPlay: (c) => c.repeat(reverse: true), delay: delay.ms)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.15, 1.15),
          duration: 4.seconds,
          curve: Curves.easeInOut,
        )
        .fade(begin: 0.6, end: 1.0, duration: 3.seconds);
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: orb,
    );
  }
}

/// Premium Glass Card with neon borders
class NeonGlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double? width;
  final double? height;
  final Color? glowColor;
  final bool showBorder;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isActive;

  const NeonGlassCard({
    super.key,
    required this.child,
    this.blur = 25.0,  // Matched to GlassCard
    this.opacity = 0.12,  // Matched to GlassCard
    this.width,
    this.height,
    this.glowColor,
    this.showBorder = true,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLG);
    final effectiveGlow = glowColor ?? AppTheme.primary;
    
    Widget content = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppTheme.spaceMD),
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            color: Colors.white.withOpacity(opacity),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity + 0.05),
                Colors.white.withOpacity(opacity * 0.5),
              ],
            ),
            border: showBorder ? Border.all(
              color: isActive 
                  ? effectiveGlow.withOpacity(0.6) 
                  : Colors.white.withOpacity(0.15),  // Increased from 0.12
              width: isActive ? 2 : 1.5,  // Increased from 1
            ) : null,
            boxShadow: isActive ? AppTheme.glowShadow(effectiveGlow, intensity: 0.7) : [
              // Add depth shadow even when not active
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

/// Interactive Button with gradient and glow
class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Gradient? gradient;
  final IconData? icon;
  final bool loading;
  final double? width;
  final Color? glowColor;
  final bool compact;

  const GlowButton({
    super.key,
    required this.text,
    required this.onTap,
    this.gradient,
    this.icon,
    this.loading = false,
    this.width,
    this.glowColor,
    this.compact = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ?? AppTheme.primaryGradient;
    final effectiveGlow = widget.glowColor ?? AppTheme.primary;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.loading) widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 20 : 28, 
          vertical: widget.compact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: [
            BoxShadow(
              color: effectiveGlow.withOpacity(_isPressed ? 0.7 : 0.5),
              blurRadius: _isPressed ? 30 : 20,
              spreadRadius: _isPressed ? 2 : -2,
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
            ] else if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated Status Indicator
class PulsingDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool animate;

  const PulsingDot({
    super.key,
    required this.color,
    this.size = 8,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    if (animate) {
      dot = dot.animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.2, 1.2), duration: 800.ms);
    }

    return dot;
  }
}

/// Shimmer Effect Container
class ShimmerContainer extends StatelessWidget {
  final Widget child;
  final bool shimmer;

  const ShimmerContainer({
    super.key,
    required this.child,
    this.shimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!shimmer) return child;
    
    return child.animate(onPlay: (c) => c.repeat())
      .shimmer(
        duration: 2.seconds,
        color: Colors.white.withOpacity(0.1),
      );
  }
}

/// Interactive Chip with glow effect
class GlowChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const GlowChip({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.elevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? color : AppTheme.subtle,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.softGlow(color) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? color : AppTheme.textMuted, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated Progress Ring
class ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 80,
    this.strokeWidth = 6,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: AppTheme.subtle,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          // Child content
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
