import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/steady_colors.dart';
import '../../theme/steady_gradients.dart';
import '../../theme/steady_motion.dart';
import '../../theme/steady_radii.dart';

class SteadyProgressBar extends StatelessWidget {
  const SteadyProgressBar({
    super.key,
    required this.value,
    required this.semanticLabel,
  });
  final double value;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    value: '${(value.clamp(0, 1) * 100).round()}%',
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: SteadyMotion.durationOf(context),
      curve: SteadyMotion.curve,
      builder: (context, progress, _) => ClipRRect(
        borderRadius: SteadyRadii.pillBorder,
        child: SizedBox(
          height: 8,
          width: double.infinity,
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: SteadyColors.border),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: SteadyGradients.progress),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SteadyProgressRing extends StatelessWidget {
  const SteadyProgressRing({
    super.key,
    required this.value,
    required this.semanticLabel,
    this.size = 48,
    this.child,
  });
  final double value;
  final String semanticLabel;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    value: '${(value.clamp(0, 1) * 100).round()}%',
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: SteadyMotion.durationOf(context),
      curve: SteadyMotion.curve,
      builder: (context, progress, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(progress),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - 3;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = SteadyColors.border;
    canvas.drawCircle(center, radius, paint);
    if (value > 0) {
      paint.shader = SteadyGradients.ring.createShader(rect);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}
