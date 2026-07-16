import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> saveAccessToken(String accessToken);
  Future<void> clear();
}

/// JWT pair storage — secure token storage on mobile. On web,
/// flutter_secure_storage falls back to browser storage — acceptable since
/// web already requires HTTPS.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage();

  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);
  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const SecureTokenStorage(),
);
