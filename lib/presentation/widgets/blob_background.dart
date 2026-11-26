import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/animation_utils.dart';

/// Animated organic blob shape that floats up and down.
class AnimatedBlob extends StatefulWidget {
  final Color color;
  final double size;
  final double opacity;
  final Duration duration;

  const AnimatedBlob({
    super.key,
    this.color = AppColors.coral,
    this.size = 200,
    this.opacity = 0.5,
    this.duration = const Duration(seconds: 6),
  });

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
      builder: (_, _) {
        final offset = sin(_controller.value * 2 * pi) * 10;
        return Transform.translate(
          offset: Offset(0, offset),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: BlobPainter(
              animValue: _controller.value,
              color: widget.color,
              opacity: widget.opacity,
            ),
          ),
        );
      },
    );
  }
}

/// Full-screen background with two decorative blobs.
class BlobBackground extends StatelessWidget {
  final Widget child;
  final Color blobColor1;
  final Color blobColor2;

  const BlobBackground({
    super.key,
    required this.child,
    this.blobColor1 = AppColors.coral,
    this.blobColor2 = AppColors.lavender,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: AnimatedBlob(
            color: blobColor1,
            size: 220,
            opacity: 0.4,
            duration: const Duration(seconds: 6),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: AnimatedBlob(
            color: blobColor2,
            size: 200,
            opacity: 0.35,
            duration: const Duration(seconds: 7),
          ),
        ),
        child,
      ],
    );
  }
}
