class QuestionOptions {
  const QuestionOptions({required this.a, required this.b, required this.c, required this.d});
  final String a;
  final String b;
  final String c;
  final String d;

  factory QuestionOptions.fromJson(Map<String, dynamic> json) => QuestionOptions(
        a: json['A'] as String? ?? '',
        b: json['B'] as String? ?? '',
        c: json['C'] as String? ?? '',
        d: json['D'] as String? ?? '',
      );

  String forKey(String key) => switch (key) {
        'A' => a,
        'B' => b,
        'C' => c,
        'D' => d,
        _ => '',
      };
}

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.marks,
    this.correctAnswer,
    this.quizId,
  });

  final int id;
  final String text;
  final QuestionOptions options;
  final int marks;
  final String? correctAnswer;
  final int? quizId;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as int,
        text: json['question'] as String? ?? '',
        options: QuestionOptions.fromJson(json['options'] as Map<String, dynamic>? ?? const {}),
        marks: json['marks'] as int? ?? 0,
        correctAnswer: json['correctAnswer'] as String?,
        quizId: json['quizId'] as int?,
      );
}
