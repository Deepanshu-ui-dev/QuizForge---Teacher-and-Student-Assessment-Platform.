import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/models/result.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/percentage_badge.dart';
import '../../student/providers/student_result_providers.dart';

class AttemptsResultsScreen extends ConsumerWidget {
  const AttemptsResultsScreen({super.key, this.quizId});
  final int? quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = quizId != null
        ? ref.watch(quizResultsProvider(quizId!))
        : ref.watch(allResultsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(quizId != null ? 'Quiz Attempts' : 'Attempts & Results')),
      body: resultsAsync.when(
        loading: () => const LoadingView(lines: 5),
        error: (e, __) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ErrorView(
            failure: FailureMapper.fromException(e),
            onRetry: () {
              if (quizId != null) {
                ref.invalidate(quizResultsProvider(quizId!));
              } else {
                ref.invalidate(allResultsProvider);
              }
            },
          ),
        ),
        data: (results) {
          if (results.isEmpty) {
            return const EmptyView(
              icon: Icons.bar_chart_outlined,
              message: 'No attempts yet',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final r = results[i];
              return _AttemptTile(result: r, showQuizTitle: quizId == null);
            },
          );
        },
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({required this.result, required this.showQuizTitle});
  final QuizResult result;
  final bool showQuizTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = showQuizTitle
        ? (result.quizTitle ?? 'Quiz #${result.quizId}')
        : (result.studentName ?? 'Student');
    final subtitle = showQuizTitle
        ? (result.studentName ?? result.studentEmail ?? '')
        : '${result.submittedAt.toLocal()}'.split('.').first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          PercentageBadge(percentage: result.percentage),
        ],
      ),
    );
  }
}
