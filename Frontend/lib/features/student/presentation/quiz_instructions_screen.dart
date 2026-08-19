import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../core/utils/difficulty_style.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_dot.dart';

const _rules = [
  'Answer every question — the backend requires a complete set of answers to submit.',
  'You can navigate between questions freely before submitting.',
  'Your score is graded entirely by the server once you submit.',
];

class QuizInstructionsScreen extends ConsumerWidget {
  const QuizInstructionsScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(quizId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Instructions')),
      body: quizAsync.when(
        loading: () => const LoadingView(),
        error: (e, __) => ErrorView(
          failure: FailureMapper.fromException(e),
          onRetry: () => ref.invalidate(quizDetailProvider(quizId)),
        ),
        data: (quiz) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quiz.title, style: theme.textTheme.displayMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(quiz.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadii.lgRadius,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      _MetaRow(icon: Icons.help_outline_rounded, label: 'Questions', value: '${quiz.stats.totalQuestions}'),
                      _MetaRow(icon: Icons.timer_outlined, label: 'Duration', value: '${quiz.duration} min'),
                      Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text('Difficulty', style: theme.textTheme.bodyMedium)),
                          StatusDot(color: quiz.difficulty.dotColor),
                          const SizedBox(width: 6),
                          Text(quiz.difficulty.label, style: theme.textTheme.labelLarge),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Rules', style: theme.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                ..._rules.map((rule) => _RuleRow(text: rule)),
                const Spacer(),
                AppButton(
                  label: 'Start Quiz',
                  onPressed: () => context.pushReplacement('${AppRoutes.takeQuiz}/$quizId'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.accentIndigo),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}
