import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String token,
    required int userId,
    required String name,
    required String email,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.jwtToken, value: token),
      _storage.write(key: StorageKeys.userId, value: userId.toString()),
      _storage.write(key: StorageKeys.userName, value: name),
      _storage.write(key: StorageKeys.userEmail, value: email),
      _storage.write(key: StorageKeys.userRole, value: role),
    ]);
  }

  Future<String?> get token => _storage.read(key: StorageKeys.jwtToken);
  Future<String?> get userName => _storage.read(key: StorageKeys.userName);
  Future<String?> get userEmail => _storage.read(key: StorageKeys.userEmail);
  Future<String?> get userRole => _storage.read(key: StorageKeys.userRole);

  Future<int?> get userId async {
    final raw = await _storage.read(key: StorageKeys.userId);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<bool> get hasSession async => (await token) != null;

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.jwtToken),
      _storage.delete(key: StorageKeys.userId),
      _storage.delete(key: StorageKeys.userName),
      _storage.delete(key: StorageKeys.userEmail),
      _storage.delete(key: StorageKeys.userRole),
    ]);
  }

  Future<bool> get onboardingSeen async {
    final value = await _storage.read(key: StorageKeys.onboardingSeen);
    return value == 'true';
  }

  Future<void> setOnboardingSeen() =>
      _storage.write(key: StorageKeys.onboardingSeen, value: 'true');
}
