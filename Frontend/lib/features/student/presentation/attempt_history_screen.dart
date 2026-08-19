import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/percentage_badge.dart';
import '../providers/student_result_providers.dart';

class AttemptHistoryScreen extends ConsumerWidget {
  const AttemptHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(myResultsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Attempt History')),
      body: resultsAsync.when(
        loading: () => const LoadingView(lines: 5),
        error: (e, __) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ErrorView(
            failure: FailureMapper.fromException(e),
            onRetry: () => ref.invalidate(myResultsProvider),
          ),
        ),
        data: (results) {
          if (results.isEmpty) {
            return const EmptyView(icon: Icons.history_rounded, message: 'No attempts yet');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final r = results[i];
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
                          Text(r.quizTitle ?? 'Quiz #${r.quizId}', style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 2),
                          Text(
                            '${r.submittedAt.toLocal()}'.split('.').first,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    PercentageBadge(percentage: r.percentage),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
