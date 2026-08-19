import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'stat_ring.dart';

class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.size = 64,
    this.strokeWidth = 6,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;
    final color = ratio <= 0.1
        ? AppColors.error
        : ratio <= 0.2
            ? AppColors.warning
            : AppColors.accentIndigo;

    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return StatRing(
      progress: ratio,
      centerText: '$minutes:$seconds',
      size: size,
      strokeWidth: strokeWidth,
      color: color,
    );
  }
}
