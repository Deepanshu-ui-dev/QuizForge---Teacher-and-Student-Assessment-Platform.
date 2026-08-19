import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/hero_header.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/quiz_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/staggered_fade_in.dart';
import '../../../shared/widgets/stat_card.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final quizzesAsync = ref.watch(quizListProvider(const QuizListParams()));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(quizListProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            HeroHeader(
              title: 'Good day, ${sessionAsync.value?.name ?? ''}',
              subtitle: 'Here\'s what\'s happening with your quizzes.',
              trailing: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.createQuiz),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: quizzesAsync.when(
                loading: () => const _StatsRowSkeleton(),
                error: (_, __) => const SizedBox(),
                data: (result) {
                  final totalQuizzes = result.pagination.total;
                  final totalQuestions =
                      result.data.fold<int>(0, (sum, q) => sum + q.stats.totalQuestions);
                  final totalAttempts =
                      result.data.fold<int>(0, (sum, q) => sum + q.stats.totalResults);

                  return Row(
                    children: [
                      Expanded(child: StatCard(label: 'Quizzes visible', value: '$totalQuizzes', icon: Icons.menu_book_rounded)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: StatCard(label: 'Questions', value: '$totalQuestions', icon: Icons.help_outline_rounded)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: StatCard(
                          label: 'Attempts',
                          value: '$totalAttempts',
                          icon: Icons.people_alt_outlined,
                          deltaColor: AppColors.accentIndigo,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Quizzes',
              actionLabel: '+ New',
              onAction: () => context.push(AppRoutes.createQuiz),
            ),
            const SizedBox(height: AppSpacing.sm),
            quizzesAsync.when(
              loading: () => const LoadingView(),
              error: (e, __) => ErrorView(
                failure: FailureMapper.fromException(e),
                onRetry: () => ref.invalidate(quizListProvider),
              ),
              data: (result) {
                if (result.data.isEmpty) {
                  return EmptyView(
                    icon: Icons.menu_book_outlined,
                    message: 'No quizzes created yet',
                    actionLabel: 'Create your first quiz',
                    onAction: () => context.push(AppRoutes.createQuiz),
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
                            onTap: () => context.push('${AppRoutes.quizDetail}/${quiz.id}'),
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

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();
  @override
  Widget build(BuildContext context) => const SizedBox(height: 72, child: LoadingView(lines: 1));
}
