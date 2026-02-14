import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_theme.dart';

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        color: AppTheme.primaryNeon.withOpacity(0.05),
        spacing: 40.0,
      ),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _GridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    // Draw Vertical Lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw Horizontal Lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
