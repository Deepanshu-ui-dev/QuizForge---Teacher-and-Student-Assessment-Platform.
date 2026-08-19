import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/models/result.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/hero_header.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/percentage_badge.dart';
import '../../../shared/widgets/quiz_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/staggered_fade_in.dart';
import '../providers/student_result_providers.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final quizzesAsync = ref.watch(quizListProvider(const QuizListParams()));
    final myResultsAsync = ref.watch(myResultsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(quizListProvider);
          ref.invalidate(myResultsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            HeroHeader(
              title: 'Welcome back, ${sessionAsync.value?.name ?? ''}',
              subtitle: 'Ready to take on a new quiz?',
              trailing: AppButton(
                label: 'Join',
                icon: Icons.add_task_rounded,
                fullWidth: false,
                onPressed: () => context.push(AppRoutes.joinQuiz),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Recent attempts'),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: myResultsAsync.when(
                loading: () => const LoadingView(lines: 2),
                error: (e, __) => ErrorView(failure: FailureMapper.fromException(e)),
                data: (results) {
                  if (results.isEmpty) {
                    return const EmptyView(icon: Icons.history_rounded, message: 'No attempts yet');
                  }
                  return Column(
                    children: results.take(3).toList().asMap().entries.map((entry) {
                      return StaggeredFadeIn(index: entry.key, child: _ResultRow(result: entry.value));
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Available quizzes'),
            const SizedBox(height: AppSpacing.sm),
            quizzesAsync.when(
              loading: () => const LoadingView(lines: 4),
              error: (e, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ErrorView(
                  failure: FailureMapper.fromException(e),
                  onRetry: () => ref.invalidate(quizListProvider),
                ),
              ),
              data: (result) {
                if (result.data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: EmptyView(icon: Icons.menu_book_outlined, message: 'No quizzes available yet'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: result.data.asMap().entries.map((entry) {
                      final quiz = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: StaggeredFadeIn(
                          index: entry.key,
                          child: QuizCard(
                            quiz: quiz,
                            onTap: () => context.push('${AppRoutes.quizInstructions}/${quiz.id}'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.mdRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentIndigo.withValues(alpha: 0.1),
              borderRadius: AppRadii.smRadius,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 18,
              color: AppColors.accentIndigo,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              result.quizTitle ?? 'Quiz #${result.quizId}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          PercentageBadge(percentage: result.percentage),
        ],
      ),
    );
  }
}
