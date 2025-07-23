import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedWavePainter extends CustomPainter {
  final double waveShift;
  final Color startColor;
  final Color endColor;

  AnimatedWavePainter({
    required this.waveShift,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final double baseHeight = size.height * 0.35;
    final double waveHeight = size.height * 0.1;

    path.moveTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      final y =
          baseHeight + sin((x + waveShift) * 2 * pi / size.width) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedWavePainter oldDelegate) {
    return oldDelegate.waveShift != waveShift;
  }
}
