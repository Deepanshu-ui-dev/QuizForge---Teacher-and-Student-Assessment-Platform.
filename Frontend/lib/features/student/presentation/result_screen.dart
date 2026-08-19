import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/result.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/stat_ring.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              _AnimatedScoreRing(
                percentage: result.percentage,
                subLabel: '${result.score}/${result.totalMarks} marks',
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Correct',
                      value: '${result.correctAnswers}',
                      icon: Icons.check_circle_outline_rounded,
                      deltaColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      label: 'Incorrect',
                      value: '${result.wrongAnswers}',
                      icon: Icons.cancel_outlined,
                      deltaColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      label: 'Total Marks',
                      value: '${result.totalMarks}',
                      icon: Icons.stars_outlined,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (result.answers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppButton(
                    label: 'Review Answers',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => _showAnswerReview(context),
                  ),
                ),
              AppButton(
                label: 'Back to Dashboard',
                onPressed: () => context.go(AppRoutes.studentHome),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnswerReview(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              itemCount: result.answers.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final answer = result.answers[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: AppRadii.lgRadius,
                    border: Border.all(
                      color: answer.isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${i + 1}. ${answer.questionText ?? 'Question ${answer.questionId}'}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your answer: ${answer.selectedAnswer}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Correct answer: ${answer.correctAnswer}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        answer.isCorrect
                            ? '+${answer.marksAwarded} marks'
                            : '0 marks',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: answer.isCorrect ? AppColors.success : AppColors.error,
                            ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AnimatedScoreRing extends StatelessWidget {
  const _AnimatedScoreRing({required this.percentage, this.subLabel});
  final double percentage;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage.clamp(0, 100)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return StatRing(
          progress: value / 100,
          centerText: '${value.toStringAsFixed(0)}%',
          subLabel: subLabel,
        );
      },
    );
  }
}
