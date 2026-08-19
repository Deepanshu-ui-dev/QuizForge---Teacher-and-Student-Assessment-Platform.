import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

class PercentageBadge extends StatelessWidget {
  const PercentageBadge({super.key, required this.percentage});
  final double percentage;

  Color _colorForScore(bool isDark) {
    if (percentage >= 50) {
      return isDark ? AppColors.successDark : AppColors.success;
    }
    return isDark ? AppColors.errorDark : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _colorForScore(isDark);
    final label = '${percentage.round()}%';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.smRadius,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
