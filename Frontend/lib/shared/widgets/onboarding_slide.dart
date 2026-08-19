import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.icon,
    required this.headline,
    required this.supportingText,
  });

  final IconData icon;
  final String headline;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.indigoViolet),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, size: 48, color: AppColors.pureWhite),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMd(AppColors.pureWhite),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            supportingText,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLg(
              AppColors.pureWhite.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
