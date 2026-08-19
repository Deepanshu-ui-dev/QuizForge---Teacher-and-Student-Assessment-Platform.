import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../core/repositories/repository_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/form_error_banner.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/question_card.dart';
import '../../../shared/widgets/segmented_control.dart';

class QuestionBuilderScreen extends ConsumerStatefulWidget {
  const QuestionBuilderScreen({super.key, required this.quizId});
  final int quizId;

  @override
  ConsumerState<QuestionBuilderScreen> createState() => _QuestionBuilderScreenState();
}

class _QuestionBuilderScreenState extends ConsumerState<QuestionBuilderScreen> {
  final _question = TextEditingController();
  final _optionA = TextEditingController();
  final _optionB = TextEditingController();
  final _optionC = TextEditingController();
  final _optionD = TextEditingController();
  final _marks = TextEditingController(text: '1');
  String _correct = 'A';
  bool _isSaving = false;
  String? _formError;

  Future<void> _addQuestion() async {
    if (_question.text.trim().isEmpty ||
        _optionA.text.trim().isEmpty ||
        _optionB.text.trim().isEmpty ||
        _optionC.text.trim().isEmpty ||
        _optionD.text.trim().isEmpty) {
      setState(() => _formError = 'Fill in the question and all four options.');
      return;
    }
    final marks = int.tryParse(_marks.text.trim()) ?? 0;
    if (marks <= 0) {
      setState(() => _formError = 'Marks must be a positive number.');
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      await ref.read(questionRepositoryProvider).createQuestion(
            quizId: widget.quizId,
            question: _question.text.trim(),
            optionA: _optionA.text.trim(),
            optionB: _optionB.text.trim(),
            optionC: _optionC.text.trim(),
            optionD: _optionD.text.trim(),
            correctAnswer: _correct,
            marks: marks,
          );
      _question.clear();
      _optionA.clear();
      _optionB.clear();
      _optionC.clear();
      _optionD.clear();
      _marks.text = '1';
      setState(() => _correct = 'A');
      ref.invalidate(questionsByQuizProvider(widget.quizId));
      ref.invalidate(quizDetailProvider(widget.quizId));
    } catch (e) {
      setState(() => _formError = FailureMapper.fromException(e).message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteQuestion(int questionId) async {
    final confirmed = await showConfirmBottomSheet(
      context,
      title: 'Delete question?',
      message: 'This cannot be undone. Questions with existing student attempts cannot be deleted.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;
    try {
      await ref.read(questionRepositoryProvider).deleteQuestion(questionId);
      ref.invalidate(questionsByQuizProvider(widget.quizId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(FailureMapper.fromException(e).message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsByQuizProvider(widget.quizId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Questions')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Add a question', style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadii.lgRadius,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_formError != null) ...[
                  FormErrorBanner(message: _formError!),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppTextField(label: 'Question', controller: _question),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Option A', controller: _optionA),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Option B', controller: _optionB),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Option C', controller: _optionC),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(label: 'Option D', controller: _optionD),
                const SizedBox(height: AppSpacing.md),
                Text('Correct answer', style: theme.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                SegmentedControl<String>(
                  options: const ['A', 'B', 'C', 'D'],
                  labels: const ['A', 'B', 'C', 'D'],
                  selected: _correct,
                  onChanged: (v) => setState(() => _correct = v),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Marks', controller: _marks, keyboardType: TextInputType.number),
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: 'Add Question', isLoading: _isSaving, onPressed: _addQuestion),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Questions in this quiz', style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.md),
          questionsAsync.when(
            loading: () => const LoadingView(lines: 3),
            error: (e, __) => ErrorView(
              failure: FailureMapper.fromException(e),
              onRetry: () => ref.invalidate(questionsByQuizProvider(widget.quizId)),
            ),
            data: (questions) {
              if (questions.isEmpty) {
                return const EmptyView(icon: Icons.quiz_outlined, message: 'No questions added yet');
              }
              return Column(
                children: questions.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: QuestionCard(
                      question: entry.value,
                      index: entry.key + 1,
                      onDelete: () => _deleteQuestion(entry.value.id),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
