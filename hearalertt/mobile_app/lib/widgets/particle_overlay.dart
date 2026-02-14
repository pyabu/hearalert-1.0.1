import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ParticleOverlay extends StatefulWidget {
  final Color color;
  final int numberOfParticles;

  const ParticleOverlay({
    super.key,
    this.color = Colors.white,
    this.numberOfParticles = 50,
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
  late List<_Particle> _particles;
  late Ticker _ticker;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.numberOfParticles, (index) => _createParticle());
    _ticker = createTicker(_onTick)..start();
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: _random.nextDouble() * 0.2 + 0.05,
      theta: _random.nextDouble() * 2 * pi,
      radius: _random.nextDouble() * 2 + 0.5,
      opacity: _random.nextDouble() * 0.5 + 0.1,
    );
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    setState(() {
      for (var particle in _particles) {
        particle.y -= particle.speed * 0.01; // Float upwards
        particle.x += sin(particle.theta) * 0.001; // Meander horizontally
        particle.theta += 0.05;

        // Reset if off screen
        if (particle.y < 0) {
          particle.y = 1.0;
          particle.x = _random.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(_particles, widget.color),
      size: Size.infinite,
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double theta;
  double radius;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.theta,
    required this.radius,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = color.withOpacity(particle.opacity);
       // Responsive positioning
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
