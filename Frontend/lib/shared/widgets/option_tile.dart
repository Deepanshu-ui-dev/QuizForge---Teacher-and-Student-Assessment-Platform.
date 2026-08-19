import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

enum OptionReviewState { none, correct, incorrect }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.keyLabel,
    required this.text,
    required this.isSelected,
    this.onTap,
    this.reviewState = OptionReviewState.none,
  });

  final String keyLabel;
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final OptionReviewState reviewState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color borderColor = theme.colorScheme.outlineVariant;
    Color? fillColor;
    Widget? trailingIcon;

    switch (reviewState) {
      case OptionReviewState.correct:
        fillColor = AppColors.success.withValues(alpha: 0.08);
        borderColor = AppColors.success;
        trailingIcon = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20);
        break;
      case OptionReviewState.incorrect:
        fillColor = AppColors.error.withValues(alpha: 0.08);
        borderColor = AppColors.error;
        trailingIcon = const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20);
        break;
      case OptionReviewState.none:
        if (isSelected) {
          borderColor = AppColors.accentIndigo;
          trailingIcon = const Icon(Icons.check_circle_rounded, color: AppColors.accentIndigo, size: 20);
        }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: fillColor ?? theme.colorScheme.surface,
            borderRadius: AppRadii.mdRadius,
            border: Border.all(
              color: borderColor,
              width: isSelected || reviewState != OptionReviewState.none ? 1.6 : 1,
            ),
            boxShadow: isSelected && reviewState == OptionReviewState.none
                ? [
                    BoxShadow(
                      color: AppColors.accentIndigo.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.accentIndigo.withValues(alpha: 0.1)
                        : null,
                    border: Border.all(
                      color: isSelected ? AppColors.accentIndigo : theme.colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    keyLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected ? AppColors.accentIndigo : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
