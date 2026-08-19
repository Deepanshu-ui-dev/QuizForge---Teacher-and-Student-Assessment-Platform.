import 'package:dio/dio.dart';
import '../errors/failure_mapper.dart';
import '../models/result.dart';
import '../network/api_endpoints.dart';

class ResultRepository {
  ResultRepository(this._dio);
  final Dio _dio;

  Future<QuizResult> submitQuiz({
    required int quizId,
    required List<({int questionId, String answer})> answers,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.submitAttempt(quizId.toString()),
        data: {
          'answers': answers
              .map((a) => {'questionId': a.questionId, 'answer': a.answer})
              .toList(),
        },
      );
      return QuizResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<List<QuizResult>> getMyResults() async {
    try {
      final response = await _dio.get(ApiEndpoints.myResults);
      return (response.data['data'] as List<dynamic>)
          .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<Map<String, dynamic>> getMyStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.myStats);
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<QuizResult> getResultById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.resultById(id.toString()));
      return QuizResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<List<QuizResult>> getAllResults() async {
    try {
      final response = await _dio.get(ApiEndpoints.results);
      return (response.data['data'] as List<dynamic>)
          .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<List<QuizResult>> getQuizResults(int quizId) async {
    try {
      final response = await _dio.get(ApiEndpoints.quizResults(quizId.toString()));
      return (response.data['data'] as List<dynamic>)
          .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }
}
