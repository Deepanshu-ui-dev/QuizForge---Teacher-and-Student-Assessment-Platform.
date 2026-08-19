class QuizAttemptAnswerDetail {
  const QuizAttemptAnswerDetail({
    required this.questionId,
    this.questionText,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.marksAwarded,
  });

  final int questionId;
  final String? questionText;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int marksAwarded;

  factory QuizAttemptAnswerDetail.fromJson(Map<String, dynamic> json) => QuizAttemptAnswerDetail(
        questionId: json['questionId'] as int,
        questionText: json['question'] as String?,
        selectedAnswer: json['selectedAnswer'] as String? ?? '',
        correctAnswer: json['correctAnswer'] as String? ?? '',
        isCorrect: json['isCorrect'] as bool? ?? false,
        marksAwarded: json['marksAwarded'] as int? ?? 0,
      );
}

class QuizResult {
  const QuizResult({
    required this.id,
    required this.quizId,
    this.quizTitle,
    this.quizDifficulty,
    this.studentName,
    this.studentEmail,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.submittedAt,
    this.answers = const [],
  });

  final int id;
  final int quizId;
  final String? quizTitle;
  final String? quizDifficulty;
  final String? studentName;
  final String? studentEmail;
  final int score;
  final int totalMarks;
  final double percentage;
  final int correctAnswers;
  final int wrongAnswers;
  final DateTime submittedAt;
  final List<QuizAttemptAnswerDetail> answers;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    final quiz = json['quiz'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    return QuizResult(
      id: json['id'] as int,
      quizId: quiz != null ? quiz['id'] as int : (json['quizId'] as int? ?? 0),
      quizTitle: quiz?['title'] as String?,
      quizDifficulty: quiz?['difficulty'] as String?,
      studentName: user?['name'] as String?,
      studentEmail: user?['email'] as String?,
      score: json['score'] as int? ?? 0,
      totalMarks: json['totalMarks'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => QuizAttemptAnswerDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
