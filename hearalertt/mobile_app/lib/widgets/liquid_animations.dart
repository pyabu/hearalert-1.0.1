import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_theme.dart';

/// Animated flowing gradient overlay for liquid glass effect
class LiquidGradientFlow extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final Alignment begin;
  final Alignment end;
  final bool animate;

  const LiquidGradientFlow({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.animate = true,
  });

  @override
  State<LiquidGradientFlow> createState() => _LiquidGradientFlowState();
}

class _LiquidGradientFlowState extends State<LiquidGradientFlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              begin: widget.begin,
              end: widget.end,
              colors: widget.colors,
              stops: [
                (t - 0.3).clamp(0.0, 1.0),
                (t - 0.1).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.overlay,
          child: widget.child,
        );
      },
    );
  }
}

/// Expanding ripple effect for touch interactions
class RippleEffect extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color rippleColor;
  final Duration duration;

  const RippleEffect({
    super.key,
    this.onTap,
    required this.child,
    this.rippleColor = Colors.white,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: CustomPaint(
        painter: _tapPosition != null
            ? _RipplePainter(
                animation: _controller,
                position: _tapPosition!,
                color: widget.rippleColor,
              )
            : null,
        child: widget.child,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Offset position;
  final Color color;

  _RipplePainter({
    required this.animation,
    required this.position,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    final radius = maxRadius * animation.value;
    final opacity = (1.0 - animation.value).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => true;
}

/// Morphing container with smooth shape transitions
class MorphingContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Duration duration;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool animate;

  const MorphingContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.duration = const Duration(milliseconds: 400),
    this.color,
    this.width,
    this.height,
    this.padding,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOutCubic,
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

/// Flowing shimmer effect for glass surfaces
class LiquidShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final bool enabled;

  const LiquidShimmer({
    super.key,
    required this.child,
    this.baseColor = Colors.transparent,
    this.highlightColor = Colors.white,
    this.duration = const Duration(seconds: 2),
    this.enabled = true,
  });

  @override
  State<LiquidShimmer> createState() => _LiquidShimmerState();
}

class _LiquidShimmerState extends State<LiquidShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(-1.0 + _controller.value * 2, 0.0),
              colors: [
                widget.baseColor,
                widget.highlightColor.withOpacity(0.3),
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Multi-layer depth effect for 3D-like liquid glass
class DepthLayer extends StatelessWidget {
  final Widget child;
  final double depth;
  final Color shadowColor;
  final double blurRadius;

  const DepthLayer({
    super.key,
    required this.child,
    this.depth = 8.0,
    this.shadowColor = Colors.black,
    this.blurRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Shadow layer
        Transform.translate(
          offset: Offset(0, depth / 2),
          child: Opacity(
            opacity: 0.3,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
        // Main content
        child,
      ],
    );
  }
}

/// Pulsating glow effect for active elements
class PulsatingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minIntensity;
  final double maxIntensity;
  final Duration duration;
  final bool enabled;

  const PulsatingGlow({
    super.key,
    required this.child,
    required this.glowColor,
    this.minIntensity = 0.3,
    this.maxIntensity = 0.8,
    this.duration = const Duration(seconds: 2),
    this.enabled = true,
  });

  @override
  State<PulsatingGlow> createState() => _PulsatingGlowState();
}

class _PulsatingGlowState extends State<PulsatingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: widget.minIntensity,
      end: widget.maxIntensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value),
                blurRadius: 30 * _animation.value,
                spreadRadius: 5 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Liquid loading indicator with wave effect
class LiquidLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const LiquidLoadingIndicator({
    super.key,
    this.size = 40,
    this.color = AppTheme.primary,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<LiquidLoadingIndicator> createState() => _LiquidLoadingIndicatorState();
}

class _LiquidLoadingIndicatorState extends State<LiquidLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LiquidWavePainter(
              animation: _controller,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _LiquidWavePainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.2;
    final waveLength = size.width;
    final progress = animation.value;

    path.moveTo(0, size.height / 2);

    for (double i = 0; i <= waveLength; i++) {
      final x = i;
      final y = size.height / 2 +
          sin((i / waveLength * 2 * pi) + (progress * 2 * pi)) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidWavePainter oldDelegate) => true;
}
