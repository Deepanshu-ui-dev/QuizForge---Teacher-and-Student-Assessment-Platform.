import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppGradients.indigoViolet),
            ),
          ),
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pureWhite.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pureWhite.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: AppRadii.lgRadius,
                      boxShadow: AppShadows.hero,
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: AppColors.accentIndigo,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'QuizForge',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: AppColors.pureWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Create quizzes, join with a code, and see backend-graded results instantly.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.pureWhite.withValues(alpha: 0.88),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pureWhite,
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
                        elevation: 0,
                      ),
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.pureWhite,
                        side: BorderSide(color: AppColors.pureWhite.withValues(alpha: 0.7)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
                      ),
                      onPressed: () => context.push(AppRoutes.login),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
