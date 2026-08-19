import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paginated.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../repositories/repository_providers.dart';

class QuizListParams {
  const QuizListParams({this.search, this.difficulty});
  final String? search;
  final QuizDifficulty? difficulty;

  @override
  bool operator ==(Object other) =>
      other is QuizListParams && other.search == search && other.difficulty == difficulty;

  @override
  int get hashCode => Object.hash(search, difficulty);
}

final quizListProvider =
    FutureProvider.autoDispose.family<PaginatedResult<Quiz>, QuizListParams>((ref, params) {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.getQuizzes(search: params.search, difficulty: params.difficulty);
});

final quizDetailProvider = FutureProvider.autoDispose.family<Quiz, int>((ref, quizId) {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.getQuizById(quizId);
});

final questionsByQuizProvider =
    FutureProvider.autoDispose.family<List<Question>, int>((ref, quizId) {
  final repo = ref.watch(questionRepositoryProvider);
  return repo.getQuestionsByQuiz(quizId);
});
