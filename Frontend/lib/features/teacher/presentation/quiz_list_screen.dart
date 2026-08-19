import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/models/quiz.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/quiz_card.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/staggered_fade_in.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  QuizDifficulty? _difficulty;
  final _search = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final params = QuizListParams(search: _query.isEmpty ? null : _query, difficulty: _difficulty);
    final quizzesAsync = ref.watch(quizListProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('My Quizzes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createQuiz),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: AppTextField(
              label: 'Search',
              hintText: 'Search quizzes…',
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SegmentedControl<QuizDifficulty?>(
              options: const [null, QuizDifficulty.easy, QuizDifficulty.medium, QuizDifficulty.hard],
              labels: const ['All', 'Easy', 'Medium', 'Hard'],
              selected: _difficulty,
              onChanged: (v) => setState(() => _difficulty = v),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: quizzesAsync.when(
              loading: () => const LoadingView(lines: 6),
              error: (e, __) => ErrorView(
                failure: FailureMapper.fromException(e),
                onRetry: () => ref.invalidate(quizListProvider),
              ),
              data: (result) {
                if (result.data.isEmpty) {
                  return const EmptyView(icon: Icons.search_off_rounded, message: 'No quizzes match your filters');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                  itemCount: result.data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final quiz = result.data[i];
                    return StaggeredFadeIn(
                      index: i,
                      child: QuizCard(
                        quiz: quiz,
                        onTap: () => context.push('${AppRoutes.quizDetail}/${quiz.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
