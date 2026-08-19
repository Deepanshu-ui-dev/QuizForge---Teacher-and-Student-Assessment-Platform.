import 'package:dio/dio.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final SecureStorageService _storage;

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return AppUser.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<AppUser> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      await _storage.saveSession(
        token: token,
        userId: user.id,
        name: user.name,
        email: user.email,
        role: user.backendRole,
      );

      return user;
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<bool> validateSession() async {
    try {
      await _dio.get(ApiEndpoints.profile);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() => _storage.clearSession();
}
