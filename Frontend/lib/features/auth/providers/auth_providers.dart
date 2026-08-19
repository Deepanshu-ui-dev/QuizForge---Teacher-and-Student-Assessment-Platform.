import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/repositories/repository_providers.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<AppUser?> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      ref.invalidate(sessionProvider);
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      final failure = FailureMapper.fromException(e);
      state = AsyncError(failure, st);
      return null;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(name: name, email: email, password: password, role: role);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      final failure = FailureMapper.fromException(e);
      state = AsyncError(failure, st);
      return false;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.invalidate(sessionProvider);
  }

  Failure? get currentFailure => state.hasError ? state.error as Failure : null;
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
