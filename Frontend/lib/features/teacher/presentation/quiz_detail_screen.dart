import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../core/repositories/repository_providers.dart';
import '../../../core/utils/difficulty_style.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_dot.dart';

class QuizDetailScreen extends ConsumerStatefulWidget {
  const QuizDetailScreen({super.key, required this.quizId});
  final int quizId;

  @override
  ConsumerState<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends ConsumerState<QuizDetailScreen> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmBottomSheet(
      context,
      title: 'Delete quiz?',
      message:
          'This will permanently delete the quiz, all its questions, and all student attempt records. This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(quizRepositoryProvider).deleteQuiz(widget.quizId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FailureMapper.fromException(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizDetailProvider(widget.quizId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
        actions: [
          quizAsync.maybeWhen(
            data: (_) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/teacher/quizzes/${widget.quizId}/edit'),
            ),
            orElse: () => const SizedBox(),
          ),
          quizAsync.maybeWhen(
            data: (_) => _deleting
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.error,
                    tooltip: 'Delete quiz',
                    onPressed: _confirmDelete,
                  ),
            orElse: () => const SizedBox(),
          ),
        ],
      ),
      body: quizAsync.when(
        loading: () => const LoadingView(),
        error: (e, __) => ErrorView(
          failure: FailureMapper.fromException(e),
          onRetry: () => ref.invalidate(quizDetailProvider(widget.quizId)),
        ),
        data: (quiz) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(quiz.title, style: theme.textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(quiz.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  StatusDot(color: quiz.difficulty.dotColor),
                  const SizedBox(width: AppSpacing.xs),
                  Text(quiz.difficulty.label, style: theme.textTheme.bodySmall),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.timer_outlined, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${quiz.duration} min', style: theme.textTheme.bodySmall),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.help_outline_rounded, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${quiz.stats.totalQuestions} questions', style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withValues(alpha: 0.06),
                  borderRadius: AppRadii.lgRadius,
                  border: Border.all(color: AppColors.accentIndigo.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Share with students', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'A real join-code system isn\'t supported by the backend yet — every quiz is visible to all students. For now, share this Quiz ID so they can find it directly:',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: AppRadii.mdRadius,
                              border: Border.all(color: theme.colorScheme.outlineVariant),
                            ),
                            child: Text(
                              '${quiz.id}',
                              style: theme.textTheme.displaySmall
                                  ?.copyWith(fontFamily: 'monospace', letterSpacing: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '${quiz.id}'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Quiz ID copied')));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Manage Questions',
                icon: Icons.list_alt_rounded,
                onPressed: () => context.push('/teacher/quizzes/${widget.quizId}/questions'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Results',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.bar_chart_rounded,
                      onPressed: () => context.push('/teacher/quizzes/${widget.quizId}/results'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Analytics',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.insights_outlined,
                      onPressed: () => context.push('/teacher/quizzes/${widget.quizId}/analytics'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
