import 'package:dio/dio.dart';
import '../errors/failure_mapper.dart';
import '../models/question.dart';
import '../network/api_endpoints.dart';

class QuestionRepository {
  QuestionRepository(this._dio);
  final Dio _dio;

  Future<List<Question>> getQuestionsByQuiz(int quizId) async {
    try {
      final response = await _dio.get(ApiEndpoints.questionsByQuiz(quizId.toString()));
      return (response.data['data'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<Question> createQuestion({
    required int quizId,
    required String question,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    required int marks,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.questions, data: {
        'quizId': quizId,
        'question': question,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctAnswer': correctAnswer,
        'marks': marks,
      });
      return Question.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<Question> updateQuestion({
    required int id,
    String? question,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    int? marks,
  }) async {
    try {
      final response = await _dio.patch(ApiEndpoints.questionById(id.toString()), data: {
        if (question != null) 'question': question,
        if (optionA != null) 'optionA': optionA,
        if (optionB != null) 'optionB': optionB,
        if (optionC != null) 'optionC': optionC,
        if (optionD != null) 'optionD': optionD,
        if (correctAnswer != null) 'correctAnswer': correctAnswer,
        if (marks != null) 'marks': marks,
      });
      return Question.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<void> deleteQuestion(int id) async {
    try {
      await _dio.delete(ApiEndpoints.questionById(id.toString()));
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }
}
