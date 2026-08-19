import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/result.dart';
import '../../../core/repositories/repository_providers.dart';

final myResultsProvider = FutureProvider.autoDispose<List<QuizResult>>((ref) {
  return ref.watch(resultRepositoryProvider).getMyResults();
});

final allResultsProvider = FutureProvider.autoDispose<List<QuizResult>>((ref) {
  return ref.watch(resultRepositoryProvider).getAllResults();
});

final quizResultsProvider =
    FutureProvider.autoDispose.family<List<QuizResult>, int>((ref, quizId) {
  return ref.watch(resultRepositoryProvider).getQuizResults(quizId);
});
