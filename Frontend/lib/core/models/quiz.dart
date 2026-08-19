class QuizCreator {
  const QuizCreator({required this.id, required this.name, required this.email});
  final int id;
  final String name;
  final String email;

  factory QuizCreator.fromJson(Map<String, dynamic> json) => QuizCreator(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}

class QuizStats {
  const QuizStats({required this.totalQuestions, required this.totalResults});
  final int totalQuestions;
  final int totalResults;

  factory QuizStats.fromJson(Map<String, dynamic>? json) => QuizStats(
        totalQuestions: json?['totalQuestions'] as int? ?? 0,
        totalResults: json?['totalResults'] as int? ?? 0,
      );
}

enum QuizDifficulty {
  easy,
  medium,
  hard;

  static QuizDifficulty fromBackend(String value) {
    switch (value) {
      case 'EASY':
        return QuizDifficulty.easy;
      case 'HARD':
        return QuizDifficulty.hard;
      case 'MEDIUM':
      default:
        return QuizDifficulty.medium;
    }
  }

  String get backendValue => switch (this) {
        QuizDifficulty.easy => 'EASY',
        QuizDifficulty.medium => 'MEDIUM',
        QuizDifficulty.hard => 'HARD',
      };

  String get label => switch (this) {
        QuizDifficulty.easy => 'Easy',
        QuizDifficulty.medium => 'Medium',
        QuizDifficulty.hard => 'Hard',
      };
}

class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.createdAt,
    this.creator,
    required this.stats,
  });

  final int id;
  final String title;
  final String description;
  final int duration;
  final QuizDifficulty difficulty;
  final DateTime createdAt;
  final QuizCreator? creator;
  final QuizStats stats;

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        duration: json['duration'] as int? ?? 0,
        difficulty: QuizDifficulty.fromBackend(json['difficulty'] as String? ?? 'MEDIUM'),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        creator: json['creator'] != null
            ? QuizCreator.fromJson(json['creator'] as Map<String, dynamic>)
            : null,
        stats: QuizStats.fromJson(json['stats'] as Map<String, dynamic>?),
      );
}
