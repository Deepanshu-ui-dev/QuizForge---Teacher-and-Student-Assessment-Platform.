import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/option_tile.dart';
import '../../../shared/widgets/timer_ring.dart';
import '../providers/take_quiz_provider.dart';
import 'review_submit_screen.dart';

class TakeQuizScreen extends ConsumerWidget {
  const TakeQuizScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(takeQuizControllerProvider(quizId));
    final controller = ref.read(takeQuizControllerProvider(quizId).notifier);

    ref.listen(takeQuizControllerProvider(quizId), (prev, next) {
      final expired = next.valueOrNull?.timeExpired ?? false;
      final wasExpired = prev?.valueOrNull?.timeExpired ?? false;
      if (expired && !wasExpired) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Time's up! Please review and submit.")),
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReviewSubmitScreen(quizId: quizId)),
        );
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: stateAsync.when(
            loading: () => const LoadingView(),
            error: (e, __) => ErrorView(failure: FailureMapper.fromException(e)),
            data: (state) {
              final question = state.currentQuestion;
              final selected = state.answers[question.id];
              final progress = (state.currentIndex + 1) / state.questions.length;
              final isLast = state.currentIndex == state.questions.length - 1;

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${state.currentIndex + 1} of ${state.questions.length}',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOut,
                                  builder: (context, value, _) => LinearProgressIndicator(
                                    value: value,
                                    minHeight: 6,
                                    backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        TimerRing(
                          remainingSeconds: state.remainingSeconds,
                          totalSeconds: state.totalSeconds,
                          size: 56,
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: SingleChildScrollView(
                          key: ValueKey(question.id),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(question.text, style: Theme.of(context).textTheme.displaySmall),
                              const SizedBox(height: AppSpacing.lg),
                              ...['A', 'B', 'C', 'D'].map((k) => Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                    child: OptionTile(
                                      keyLabel: k,
                                      text: question.options.forKey(k),
                                      isSelected: selected == k,
                                      onTap: () => controller.selectAnswer(question.id, k),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (state.currentIndex > 0)
                          Expanded(
                            child: AppButton(
                              label: 'Previous',
                              variant: AppButtonVariant.outlined,
                              onPressed: controller.previous,
                            ),
                          ),
                        if (state.currentIndex > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: isLast ? 'Review & Submit' : 'Next',
                            onPressed: () {
                              if (isLast) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ReviewSubmitScreen(quizId: quizId)),
                                );
                              } else {
                                controller.next();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
