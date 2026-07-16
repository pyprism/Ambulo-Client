import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/local/secure_token_storage.dart';
import '../../data/repositories/device_repository.dart';
import 'auth_user.dart';

/// Null = signed out / local-only. Non-null = signed in to the configured
/// BYO-server (register/login against it).
class AuthController extends AsyncNotifier<AuthUser?> {
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  @override
  Future<AuthUser?> build() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) return null;
    return _fetchMe();
  }

  Future<AuthUser?> _fetchMe() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/accounts/users/me/');
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.post(
        '/api/token/',
        data: {'username': username, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveTokens(
        accessToken: data['access'] as String,
        refreshToken: data['refresh'] as String,
      );
      final user = await _fetchMe();
      state = AsyncData(user);
      if (user != null) {
        await ref
            .read(deviceRepositoryProvider)
            .registerWithServer(dio, userId: user.id);
      }
      return null;
    } on DioException catch (e) {
      return describeDioError(e);
    }
  }

  /// Returns null on success, or an error message on failure. Registration
  /// alone doesn't issue tokens server-side, so a successful register is
  /// immediately followed by a login.
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final dio = ref.read(dioProvider);
    try {
      await dio.post(
        '/api/accounts/users/register/',
        data: {'username': username, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      return describeDioError(e);
    }
    return login(username: username, password: password);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await ref
            .read(dioProvider)
            .post('/api/token/blacklist/', data: {'refresh': refreshToken});
      } catch (_) {
        // Best-effort: still wipe local tokens even if the server call fails.
      }
    }
    await _tokenStorage.clear();
    state = const AsyncData(null);
  }

  /// Called by the Dio auth interceptor when a refresh attempt fails.
  Future<void> handleSignedOut() async {
    state = const AsyncData(null);
  }

  /// Null clears retention (keep forever); otherwise the server purges
  /// location points older than this many days.
  Future<String?> setLocationRetentionDays(int? days) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.patch(
        '/api/accounts/users/me/',
        data: {'location_retention_days': days},
      );
      state = AsyncData(
        AuthUser.fromJson(response.data as Map<String, dynamic>),
      );
      return null;
    } on DioException catch (e) {
      return describeDioError(e);
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);
