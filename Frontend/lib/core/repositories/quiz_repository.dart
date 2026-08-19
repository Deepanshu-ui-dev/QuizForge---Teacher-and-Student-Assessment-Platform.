import 'package:dio/dio.dart';
import '../errors/failure_mapper.dart';
import '../models/paginated.dart';
import '../models/quiz.dart';
import '../network/api_endpoints.dart';

class QuizRepository {
  QuizRepository(this._dio);
  final Dio _dio;

  Future<PaginatedResult<Quiz>> getQuizzes({
    int page = 1,
    int limit = 20,
    String? search,
    QuizDifficulty? difficulty,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
  }) async {
    try {
      final response = await _dio.get(ApiEndpoints.quizzes, queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (difficulty != null) 'difficulty': difficulty.backendValue,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      });
      final body = response.data as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>)
          .map((e) => Quiz.fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedResult(
        data: list,
        pagination: Pagination.fromJson(body['pagination'] as Map<String, dynamic>),
      );
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<Quiz> getQuizById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.quizById(id.toString()));
      return Quiz.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<Quiz> createQuiz({
    required String title,
    required String description,
    required int duration,
    required QuizDifficulty difficulty,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.quizzes, data: {
        'title': title,
        'description': description,
        'duration': duration,
        'difficulty': difficulty.backendValue,
      });
      return Quiz.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<Quiz> updateQuiz({
    required int id,
    String? title,
    String? description,
    int? duration,
    QuizDifficulty? difficulty,
  }) async {
    try {
      final response = await _dio.patch(ApiEndpoints.quizById(id.toString()), data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (duration != null) 'duration': duration,
        if (difficulty != null) 'difficulty': difficulty.backendValue,
      });
      return Quiz.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<void> deleteQuiz(int id) async {
    try {
      await _dio.delete(ApiEndpoints.quizById(id.toString()));
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

}
