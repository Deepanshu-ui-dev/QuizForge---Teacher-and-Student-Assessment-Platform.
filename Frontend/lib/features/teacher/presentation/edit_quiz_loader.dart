import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers/quiz_data_providers.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import 'create_edit_quiz_screen.dart';

class EditQuizLoader extends ConsumerWidget {
  const EditQuizLoader({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(quizId));
    return quizAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, __) => Scaffold(
        appBar: AppBar(title: const Text('Edit Quiz')),
        body: ErrorView(
          failure: FailureMapper.fromException(e),
          onRetry: () => ref.invalidate(quizDetailProvider(quizId)),
        ),
      ),
      data: (quiz) => CreateEditQuizScreen(existingQuiz: quiz),
    );
  }
}
