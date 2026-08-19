import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../core/repositories/repository_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/quiz_card.dart';

class JoinQuizScreen extends ConsumerStatefulWidget {
  const JoinQuizScreen({super.key});

  @override
  ConsumerState<JoinQuizScreen> createState() => _JoinQuizScreenState();
}

class _JoinQuizScreenState extends ConsumerState<JoinQuizScreen> {
  final _idController = TextEditingController();
  bool _isChecking = false;
  Failure? _failure;

  Future<void> _joinById() async {
    final id = int.tryParse(_idController.text.trim());
    if (id == null) {
      setState(() => _failure = const ValidationFailure('Enter a valid numeric Quiz ID'));
      return;
    }
    setState(() {
      _isChecking = true;
      _failure = null;
    });
    try {
      await ref.read(quizRepositoryProvider).getQuizById(id);
      if (mounted) context.push('${AppRoutes.quizInstructions}/$id');
    } catch (e) {
      setState(() => _failure = FailureMapper.fromException(e));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizListProvider(const QuizListParams()));

    return Scaffold(
      appBar: AppBar(title: const Text('Join a Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Enter Quiz ID', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ask your teacher for the Quiz ID they shared.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Quiz ID',
            controller: _idController,
            keyboardType: TextInputType.number,
            monospace: true,
            errorText: _failure?.message,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'Find Quiz', isLoading: _isChecking, onPressed: _joinById),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppSpacing.lg),
          Text('Or browse available quizzes', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          quizzesAsync.when(
            loading: () => const LoadingView(lines: 4),
            error: (e, __) => ErrorView(
              failure: FailureMapper.fromException(e),
              onRetry: () => ref.invalidate(quizListProvider),
            ),
            data: (result) {
              if (result.data.isEmpty) {
                return const EmptyView(icon: Icons.menu_book_outlined, message: 'No quizzes available yet');
              }
              return Column(
                children: result.data
                    .map((quiz) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: QuizCard(
                            quiz: quiz,
                            onTap: () => context.push('${AppRoutes.quizInstructions}/${quiz.id}'),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
