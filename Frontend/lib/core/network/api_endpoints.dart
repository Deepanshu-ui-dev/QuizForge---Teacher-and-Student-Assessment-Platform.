
class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/auth/profile';

  static const String quizzes = '/api/quizzes';
  static String quizById(String id) => '/api/quizzes/$id';

  static const String questions = '/api/questions';
  static String questionById(String id) => '/api/questions/$id';
  static String questionsByQuiz(String quizId) =>
      '/api/questions/quizzes/$quizId/questions';

  static String submitAttempt(String quizId) =>
      '/api/quizzes/$quizId/attempts';

  static const String results = '/api/results';
  static const String myResults = '/api/results/my';
  static const String myStats = '/api/results/stats';
  static String resultById(String id) => '/api/results/$id';
  static String quizResults(String quizId) => '/api/quizzes/$quizId/results';
}
