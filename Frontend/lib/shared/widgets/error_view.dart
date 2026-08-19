import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/errors/failure.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});
  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isNotImplemented = failure is BackendNotImplementedFailure;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNotImplemented ? Icons.hourglass_empty_rounded : Icons.error_outline_rounded,
              size: 36,
              color: isNotImplemented ? AppColors.grey500 : AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null && !isNotImplemented) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Retry', onPressed: onRetry, fullWidth: false, icon: Icons.refresh_rounded),
            ],
          ],
        ),
      ),
    );
  }
}
