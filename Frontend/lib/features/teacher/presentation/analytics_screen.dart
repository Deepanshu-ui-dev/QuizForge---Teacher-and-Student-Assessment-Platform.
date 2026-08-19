import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../student/providers/student_result_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(quizResultsProvider(quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: resultsAsync.when(
        loading: () => const LoadingView(lines: 4),
        error: (e, __) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ErrorView(
            failure: FailureMapper.fromException(e),
            onRetry: () => ref.invalidate(quizResultsProvider(quizId)),
          ),
        ),
        data: (results) {
          final count = results.length;
          final average = count == 0
              ? 0.0
              : results.fold<double>(0, (sum, r) => sum + r.percentage) / count;
          final highest = count == 0
              ? 0.0
              : results.map((r) => r.percentage).reduce((a, b) => a > b ? a : b);
          final passed = results.where((r) => r.percentage >= 50).length;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Attempts',
                      value: '$count',
                      icon: Icons.people_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      label: 'Average',
                      value: '${average.toStringAsFixed(0)}%',
                      icon: Icons.percent_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Highest',
                      value: '${highest.toStringAsFixed(0)}%',
                      icon: Icons.emoji_events_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      label: 'Passed (≥50%)',
                      value: '$passed',
                      icon: Icons.check_circle_outline_rounded,
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
