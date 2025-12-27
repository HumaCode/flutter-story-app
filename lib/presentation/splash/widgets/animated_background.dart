import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final int circleCount;
  final bool isDarkMode;

  const AnimatedBackground({
    super.key,
    this.circleCount = 18,
    this.isDarkMode = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<FloatingCircle> _circles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initCircles();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.addListener(_onAnimationTick);
    _controller.repeat();
  }

  void _onAnimationTick() {
    // Cek apakah widget masih mounted sebelum setState
    if (mounted) {
      setState(() {});
    }
  }

  void _initCircles() {
    _circles = [];

    // Warna untuk dark mode
    final darkColors = [
      const Color(0xFF6366F1).withOpacity(0.15), // Indigo
      const Color(0xFF8B5CF6).withOpacity(0.12), // Violet
      const Color(0xFFA855F7).withOpacity(0.18), // Purple
      const Color(0xFFD946EF).withOpacity(0.10), // Fuchsia
      const Color(0xFFEC4899).withOpacity(0.12), // Pink
      const Color(0xFF3B82F6).withOpacity(0.10), // Blue
      const Color(0xFF14B8A6).withOpacity(0.08), // Teal
    ];

    // Warna untuk light mode (opacity lebih rendah)
    final lightColors = [
      const Color(0xFF6366F1).withOpacity(0.10), // Indigo
      const Color(0xFF8B5CF6).withOpacity(0.12), // Violet
      const Color(0xFFA855F7).withOpacity(0.14), // Purple
      const Color(0xFFD946EF).withOpacity(0.08), // Fuchsia
      const Color(0xFFEC4899).withOpacity(0.10), // Pink
      const Color(0xFF3B82F6).withOpacity(0.08), // Blue
      const Color(0xFF14B8A6).withOpacity(0.06), // Teal
    ];

    final colors = widget.isDarkMode ? darkColors : lightColors;

    for (int i = 0; i < widget.circleCount; i++) {
      _circles.add(
        FloatingCircle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 80 + 40,
          color: colors[_random.nextInt(colors.length)],
          speedX: (_random.nextDouble() - 0.5) * 0.8,
          speedY: (_random.nextDouble() - 0.5) * 0.8,
          pulseSpeed: _random.nextDouble() * 2 + 1,
          pulsePhase: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Hapus listener sebelum dispose controller
    _controller.removeListener(_onAnimationTick);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: CirclesPainter(
          circles: _circles,
          time: DateTime.now().millisecondsSinceEpoch / 1000.0,
        ),
      ),
    );
  }
}

class FloatingCircle {
  double x;
  double y;
  double radius;
  Color color;
  double speedX;
  double speedY;
  double pulseSpeed;
  double pulsePhase;

  FloatingCircle({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speedX,
    required this.speedY,
    required this.pulseSpeed,
    required this.pulsePhase,
  });
}

class CirclesPainter extends CustomPainter {
  final List<FloatingCircle> circles;
  final double time;

  CirclesPainter({required this.circles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (var circle in circles) {
      // Update position - gerakan smooth
      circle.x += circle.speedX * 0.0003;
      circle.y += circle.speedY * 0.0003;

      // Wrap around edges
      if (circle.x < -0.2) circle.x = 1.2;
      if (circle.x > 1.2) circle.x = -0.2;
      if (circle.y < -0.2) circle.y = 1.2;
      if (circle.y > 1.2) circle.y = -0.2;

      // Calculate pulsing radius
      final pulse = sin(time * circle.pulseSpeed + circle.pulsePhase);
      final pulseRadius = circle.radius + pulse * 12;

      // Position on screen
      final centerX = circle.x * size.width;
      final centerY = circle.y * size.height;
      final center = Offset(centerX, centerY);

      // Create radial gradient for glow effect
      final gradient = RadialGradient(
        colors: [
          circle.color,
          circle.color.withOpacity(circle.color.opacity * 0.5),
          circle.color.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final rect = Rect.fromCircle(center: center, radius: pulseRadius);
      final paint = Paint()..shader = gradient.createShader(rect);

      canvas.drawCircle(center, pulseRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CirclesPainter oldDelegate) => true;
}
