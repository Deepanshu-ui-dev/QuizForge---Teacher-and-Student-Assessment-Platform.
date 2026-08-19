import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../utils/app_role.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(ref.watch(flutterSecureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(
    storage,
    onUnauthorized: () async {
      ref.invalidate(sessionProvider);
    },
  );
});

class SessionState {
  const SessionState({
    required this.isAuthenticated,
    required this.onboardingSeen,
    this.role,
    this.userId,
    this.name,
    this.email,
  });

  final bool isAuthenticated;
  final bool onboardingSeen;
  final AppRole? role;
  final int? userId;
  final String? name;
  final String? email;

  static const initial = SessionState(
    isAuthenticated: false,
    onboardingSeen: false,
  );
}

final sessionProvider = FutureProvider<SessionState>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);

  final onboardingSeen = await storage.onboardingSeen;
  final token = await storage.token;

  if (token == null || token.isEmpty) {
    return SessionState(
      isAuthenticated: false,
      onboardingSeen: onboardingSeen,
    );
  }

  final userId = await storage.userId;
  final name = await storage.userName;
  final email = await storage.userEmail;
  final backendRole = await storage.userRole;

  return SessionState(
    isAuthenticated: true,
    onboardingSeen: onboardingSeen,
    role: AppRole.fromBackendRole(backendRole),
    userId: userId,
    name: name,
    email: email,
  );
});
