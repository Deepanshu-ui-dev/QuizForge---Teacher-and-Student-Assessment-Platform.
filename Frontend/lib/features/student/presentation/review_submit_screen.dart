import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/form_error_banner.dart';
import '../../../shared/widgets/loading_view.dart';
import '../providers/take_quiz_provider.dart';
import 'result_screen.dart';

class ReviewSubmitScreen extends ConsumerStatefulWidget {
  const ReviewSubmitScreen({super.key, required this.quizId});
  final int quizId;

  @override
  ConsumerState<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends ConsumerState<ReviewSubmitScreen> {
  bool _isSubmitting = false;
  String? _submitError;

  Future<void> _submit() async {
    final confirmed = await showConfirmBottomSheet(
      context,
      title: 'Submit quiz?',
      message: "You won't be able to change your answers after submitting.",
      confirmLabel: 'Submit',
      isDestructive: false,
    );
    if (!confirmed) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      final controller = ref.read(takeQuizControllerProvider(widget.quizId).notifier);
      final result = await controller.submit(widget.quizId);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
        );
      }
    } catch (e) {
      setState(() => _submitError = FailureMapper.fromException(e).message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(takeQuizControllerProvider(widget.quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Submit')),
      body: stateAsync.when(
        loading: () => const LoadingView(),
        error: (e, __) => ErrorView(failure: FailureMapper.fromException(e)),
        data: (state) {
          final unansweredCount = state.questions.length - state.answers.length;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unansweredCount == 0
                      ? 'All ${state.questions.length} questions answered'
                      : '$unansweredCount of ${state.questions.length} questions unanswered',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (unansweredCount > 0)
                  Text(
                    'The backend requires an answer for every question before it will accept your submission.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: AppSpacing.lg),
                if (_submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: FormErrorBanner(message: _submitError!),
                  ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1,
                    ),
                    itemCount: state.questions.length,
                    itemBuilder: (context, i) {
                      final q = state.questions[i];
                      final answered = state.answers.containsKey(q.id);
                      return InkWell(
                        borderRadius: AppRadii.smRadius,
                        onTap: () {
                          ref.read(takeQuizControllerProvider(widget.quizId).notifier).goToIndex(i);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: answered
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            border: Border.all(
                              color: answered ? AppColors.success : AppColors.warning,
                            ),
                            borderRadius: AppRadii.smRadius,
                          ),
                          alignment: Alignment.center,
                          child: Text('${i + 1}', style: Theme.of(context).textTheme.labelLarge),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Submit Quiz',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
