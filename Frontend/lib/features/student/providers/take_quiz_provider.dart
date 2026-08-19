import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/question.dart';
import '../../../core/models/quiz.dart';
import '../../../core/models/result.dart';
import '../../../core/repositories/repository_providers.dart';

class TakeQuizState {
  const TakeQuizState({
    required this.quiz,
    required this.questions,
    required this.answers,
    required this.currentIndex,
    required this.remainingSeconds,
    this.timeExpired = false,
  });

  final Quiz quiz;
  final List<Question> questions;
  final Map<int, String> answers;
  final int currentIndex;
  final int remainingSeconds;
  final bool timeExpired;

  int get totalSeconds => quiz.duration * 60;
  int get answeredCount => answers.length;
  bool get allAnswered => answers.length == questions.length;
  Question get currentQuestion => questions[currentIndex];

  TakeQuizState copyWith({
    Map<int, String>? answers,
    int? currentIndex,
    int? remainingSeconds,
    bool? timeExpired,
  }) {
    return TakeQuizState(
      quiz: quiz,
      questions: questions,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      timeExpired: timeExpired ?? this.timeExpired,
    );
  }
}

class TakeQuizController extends FamilyAsyncNotifier<TakeQuizState, int> {
  Timer? _timer;

  @override
  Future<TakeQuizState> build(int quizId) async {
    final quiz = await ref.watch(quizRepositoryProvider).getQuizById(quizId);
    final questions = await ref.watch(questionRepositoryProvider).getQuestionsByQuiz(quizId);

    ref.onDispose(() => _timer?.cancel());

    final initial = TakeQuizState(
      quiz: quiz,
      questions: questions,
      answers: const {},
      currentIndex: 0,
      remainingSeconds: quiz.duration * 60,
    );
    _startTimer();
    return initial;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final current = state.valueOrNull;
      if (current == null) return;
      if (current.remainingSeconds <= 1) {
        t.cancel();
        state = AsyncData(current.copyWith(remainingSeconds: 0, timeExpired: true));
      } else {
        state = AsyncData(current.copyWith(remainingSeconds: current.remainingSeconds - 1));
      }
    });
  }

  void selectAnswer(int questionId, String answer) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = Map<int, String>.from(current.answers)..[questionId] = answer;
    state = AsyncData(current.copyWith(answers: updated));
  }

  void goToIndex(int index) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (index < 0 || index >= current.questions.length) return;
    state = AsyncData(current.copyWith(currentIndex: index));
  }

  void next() {
    final current = state.valueOrNull;
    if (current == null) return;
    goToIndex(current.currentIndex + 1);
  }

  void previous() {
    final current = state.valueOrNull;
    if (current == null) return;
    goToIndex(current.currentIndex - 1);
  }

  Future<QuizResult> submit(int quizId) async {
    _timer?.cancel();
    final current = state.requireValue;
    final repo = ref.read(resultRepositoryProvider);
    return repo.submitQuiz(
      quizId: quizId,
      answers: current.answers.entries.map((e) => (questionId: e.key, answer: e.value)).toList(),
    );
  }
}

final takeQuizControllerProvider =
    AsyncNotifierProvider.family<TakeQuizController, TakeQuizState, int>(TakeQuizController.new);
