import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

Future<bool> showNotificationPrimerSheet(
  BuildContext context, {
  required String message,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.accentIndigo),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Stay in the loop', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Enable notifications', onPressed: () => Navigator.of(context).pop(true)),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Not now',
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
