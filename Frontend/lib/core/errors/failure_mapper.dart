import 'dart:io';
import 'package:dio/dio.dart';
import 'failure.dart';

class FailureMapper {
  FailureMapper._();

  static Failure fromException(Object error) {
    if (error is Failure) return error;

    if (error is DioException) {
      return _fromDioException(error);
    }

    if (error is SocketException) {
      return const NetworkFailure();
    }

    return const UnknownFailure();
  }

  static Failure _fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Could not establish a secure connection.');
      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled.');
      case DioExceptionType.badResponse:
        return _fromResponse(e);
      case DioExceptionType.unknown:
        if (e.error is SocketException) return const NetworkFailure();
        return const UnknownFailure();
      default:
        return const UnknownFailure();
    }
  }

  static Failure _fromResponse(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    String message = 'Something went wrong. Please try again.';
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(message);
      case 401:
        return UnauthorizedFailure(message);
      case 403:
        return ServerFailure(statusCode, message);
      case 404:
        return ServerFailure(statusCode, message);
      case 409:
        return ValidationFailure(message);
      case 500:
      default:
        return ServerFailure(statusCode, message);
    }
  }
}
