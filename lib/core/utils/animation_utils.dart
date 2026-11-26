import 'dart:math';
import 'package:flutter/material.dart';

class AnimationUtils {
  AnimationUtils._();

  static const Duration defaultDuration = Duration(milliseconds: 800);
  static const Duration fastDuration = Duration(milliseconds: 400);
  static const Duration blobDuration = Duration(seconds: 6);
  static const Duration faqDuration = Duration(milliseconds: 500);

  static Tween<Offset> get revealTween =>
      Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero);

  static Tween<double> get fadeTween => Tween<double>(begin: 0.0, end: 1.0);
}

class BlobPainter extends CustomPainter {
  final double animValue;
  final Color color;
  final double opacity;

  BlobPainter({
    required this.animValue,
    required this.color,
    this.opacity = 0.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2 + sin(animValue * 2 * pi) * 10;
    final r = size.width * 0.5;

    path.moveTo(cx + r * 0.8, cy);
    path.cubicTo(
      cx + r, cy - r * 0.3,
      cx + r * 0.3, cy - r * 0.9,
      cx, cy - r * 0.8,
    );
    path.cubicTo(
      cx - r * 0.5, cy - r * 0.8,
      cx - r, cy - r * 0.2,
      cx - r * 0.9, cy + r * 0.2,
    );
    path.cubicTo(
      cx - r * 0.8, cy + r * 0.6,
      cx - r * 0.1, cy + r * 0.9,
      cx + r * 0.3, cy + r * 0.8,
    );
    path.cubicTo(
      cx + r * 0.7, cy + r * 0.7,
      cx + r * 0.6, cy + r * 0.3,
      cx + r * 0.8, cy,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}
