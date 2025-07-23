import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWave extends StatefulWidget {
  const AnimatedWave({super.key});

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 60),
          painter: AnimatedWavePainter(
            waveShift: _controller.value * 2 * pi,
            startColor: const Color(0xFFFFC1CC),
            endColor: const Color(0xFFFFE0E9),
          ),
        );
      },
    );
  }
}

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
    final Paint paint =
        Paint()
          ..shader = LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path path = Path();

    const double amplitude = 10;
    const double frequency = 2 * pi / 300; // wavelength
    final double baseHeight = size.height * 0.5;

    path.moveTo(0, baseHeight);

    // Start drawing wave beyond screen width to allow seamless scrolling
    for (double x = -size.width; x <= size.width * 2; x++) {
      final y = baseHeight + amplitude * sin(frequency * x + waveShift);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
