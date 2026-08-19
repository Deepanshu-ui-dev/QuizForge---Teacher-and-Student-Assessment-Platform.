import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/models/quiz.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../core/repositories/repository_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/form_error_banner.dart';
import '../../../shared/widgets/segmented_control.dart';

class CreateEditQuizScreen extends ConsumerStatefulWidget {
  const CreateEditQuizScreen({super.key, this.existingQuiz});
  final Quiz? existingQuiz;

  @override
  ConsumerState<CreateEditQuizScreen> createState() => _CreateEditQuizScreenState();
}

class _CreateEditQuizScreenState extends ConsumerState<CreateEditQuizScreen> {
  late final _title = TextEditingController(text: widget.existingQuiz?.title);
  late final _description = TextEditingController(text: widget.existingQuiz?.description);
  late final _duration =
      TextEditingController(text: widget.existingQuiz?.duration.toString());
  late QuizDifficulty _difficulty = widget.existingQuiz?.difficulty ?? QuizDifficulty.medium;

  bool _isSaving = false;
  Failure? _failure;

  bool get isEdit => widget.existingQuiz != null;

  String? _titleError;
  String? _descError;
  String? _durationError;

  bool _validate() {
    setState(() {
      _titleError = _title.text.trim().length < 3 ? 'Title must be at least 3 characters' : null;
      _descError =
          _description.text.trim().length < 10 ? 'Description must be at least 10 characters' : null;
      final duration = int.tryParse(_duration.text.trim());
      _durationError = (duration == null || duration <= 0) ? 'Enter a valid duration in minutes' : null;
    });
    return _titleError == null && _descError == null && _durationError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() {
      _isSaving = true;
      _failure = null;
    });
    final repo = ref.read(quizRepositoryProvider);
    try {
      final Quiz quiz;
      if (isEdit) {
        quiz = await repo.updateQuiz(
          id: widget.existingQuiz!.id,
          title: _title.text.trim(),
          description: _description.text.trim(),
          duration: int.parse(_duration.text.trim()),
          difficulty: _difficulty,
        );
      } else {
        quiz = await repo.createQuiz(
          title: _title.text.trim(),
          description: _description.text.trim(),
          duration: int.parse(_duration.text.trim()),
          difficulty: _difficulty,
        );
      }
      ref.invalidate(quizListProvider);
      if (mounted) context.pushReplacement('${AppRoutes.quizDetail}/${quiz.id}');
    } catch (e) {
      setState(() => _failure = FailureMapper.fromException(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Quiz' : 'Create Quiz')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_failure != null) ...[
                FormErrorBanner(message: _failure!.message),
                const SizedBox(height: AppSpacing.md),
              ],
              Text('Basics', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadii.lgRadius,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    AppTextField(label: 'Title', controller: _title, errorText: _titleError),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(label: 'Description', controller: _description, errorText: _descError),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Details', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
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
                    AppTextField(
                      label: 'Duration (minutes)',
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      errorText: _durationError,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Difficulty', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    SegmentedControl<QuizDifficulty>(
                      options: const [QuizDifficulty.easy, QuizDifficulty.medium, QuizDifficulty.hard],
                      labels: const ['Easy', 'Medium', 'Hard'],
                      selected: _difficulty,
                      onChanged: (v) => setState(() => _difficulty = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: isEdit ? 'Save Changes' : 'Create Quiz',
                isLoading: _isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
