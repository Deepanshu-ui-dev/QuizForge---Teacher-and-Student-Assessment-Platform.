import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

String resolveApiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (kIsWeb) return 'http://localhost:5000';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:5000';
    default:
      return 'http://localhost:5000';
  }
}

class ApiClient {
  ApiClient(this._storage, {required Future<void> Function() onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: resolveApiBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      AuthInterceptor(_storage, onUnauthorized: onUnauthorized),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // ignore: avoid_print
          print('[API] $obj');
        },
      ),
    );
  }

  late final Dio _dio;
  final SecureStorageService _storage;

  Dio get dio => _dio;
}
