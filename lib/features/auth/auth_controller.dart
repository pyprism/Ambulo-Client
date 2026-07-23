import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../core/server/server_config_controller.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/secure_token_storage.dart';
import '../../data/local/sync_preferences.dart';
import '../../data/repositories/device_repository.dart';
import '../sync/sync_controller.dart';
import 'auth_user.dart';

/// Null = signed out / local-only. Non-null = signed in to the configured
/// BYO-server (register/login against it).
class AuthController extends AsyncNotifier<AuthUser?> {
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  @override
  Future<AuthUser?> build() async {
    ref.listen(serverConfigProvider, (previous, next) {
      final previousOrigin = previous?.value;
      final nextOrigin = next.value;
      if (previousOrigin != null && previousOrigin != nextOrigin) {
        unawaited(_resetForOriginChange());
      }
    });
    final token = await _tokenStorage.readAccessToken();
    if (token == null) return null;
    final user = await _fetchMe();
    if (user != null) {
      unawaited(ref.read(syncControllerProvider.notifier).syncNow());
    }
    return user;
  }

  Future<AuthUser?> _fetchMe() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/accounts/users/me/');
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await _tokenStorage.clear();
        return null;
      }
      rethrow;
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
      if (user == null) {
        return 'The server rejected this session. Please sign in again.';
      }
      final device = await ref
          .read(deviceRepositoryProvider)
          .ensureLocalDevice();
      if (device.userId != null && device.userId != user.id.toString()) {
        await _clearLocalSession(clearTokens: false);
      }
      state = AsyncData(user);
      await ref
          .read(deviceRepositoryProvider)
          .registerWithServer(dio, userId: user.id);
      unawaited(ref.read(syncControllerProvider.notifier).syncNow());
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
    await _clearLocalSession();
    state = const AsyncData(null);
  }

  /// Called by the Dio auth interceptor when a refresh attempt fails.
  Future<void> handleSignedOut() async {
    await _clearLocalSession(clearTokens: false);
    state = const AsyncData(null);
  }

  Future<void> _clearLocalSession({bool clearTokens = true}) async {
    await ref.read(appDatabaseProvider).wipeAllLocalData();
    await SyncPreferences.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_date_of_birth');
    await prefs.remove('profile_biological_sex');
    await prefs.remove('profile_pending_upload');
    if (clearTokens) await _tokenStorage.clear();
  }

  Future<void> _resetForOriginChange() async {
    await _clearLocalSession();
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
