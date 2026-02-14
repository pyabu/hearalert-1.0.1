import 'dart:math' as math;
import 'package:flutter/material.dart';


/// Animated liquid wave background for liquid theme
class LiquidWaveBackground extends StatefulWidget {
  final List<Color> colors;
  final double height;
  
  const LiquidWaveBackground({
    super.key,
    this.colors = const [Color(0xFF667eea), Color(0xFF764ba2)],
    this.height = 200,
  });

  @override
  State<LiquidWaveBackground> createState() => _LiquidWaveBackgroundState();
}

class _LiquidWaveBackgroundState extends State<LiquidWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LiquidWavePainter(
              animationValue: _controller.value,
              colors: widget.colors,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  _LiquidWavePainter({
    required this.animationValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = size.height * 0.2;
    final waveLength = size.width;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.5 +
          math.sin((x / waveLength * 2 * math.pi) + (animationValue * 2 * math.pi)) * waveHeight +
          math.sin((x / waveLength * 3 * math.pi) - (animationValue * 3 * math.pi)) * (waveHeight * 0.5);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidWavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// Ripple effect overlay widget
class RippleOverlay extends StatefulWidget {
  final Widget child;
  final Color rippleColor;

  const RippleOverlay({
    super.key,
    required this.child,
    this.rippleColor = const Color(0xFF667eea),
  });

  @override
  State<RippleOverlay> createState() => _RippleOverlayState();
}

class _RippleOverlayState extends State<RippleOverlay>
    with TickerProviderStateMixin {
  final List<AnimationController> _rippleControllers = [];
  final List<Offset> _tapPositions = [];

  @override
  void dispose() {
    for (var controller in _rippleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addRipple(Offset position) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          final index = _rippleControllers.indexOf(controller);
          if (index != -1) {
            _rippleControllers.removeAt(index);
            _tapPositions.removeAt(index);
          }
          controller.dispose();
        });
      }
    });

    setState(() {
      _rippleControllers.add(controller);
      _tapPositions.add(position);
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _addRipple(details.localPosition),
      child: Stack(
        children: [
          widget.child,
          ...List.generate(_rippleControllers.length, (index) {
            return AnimatedBuilder(
              animation: _rippleControllers[index],
              builder: (context, child) {
                final value = _rippleControllers[index].value;
                return CustomPaint(
                  painter: _RipplePainter(
                    center: _tapPositions[index],
                    radius: value * 300,
                    opacity: 1.0 - value,
                    color: widget.rippleColor,
                  ),
                  size: Size.infinite,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter  {
  final Offset center;
  final double radius;
  final double opacity;
  final Color color;

  _RipplePainter({
    required this.center,
    required this.radius,
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.opacity != opacity;
}
