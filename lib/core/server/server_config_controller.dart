import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'server_base_url';

/// The BYO-server address. Null means local-only mode.
class ServerConfigController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  String _normalize(String input) {
    var url = input.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }

  Future<void> setServerAddress(String address) async {
    final normalized = _normalize(address);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, normalized);
    state = AsyncData(normalized);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    state = const AsyncData(null);
  }

  /// Hits /api/healthz/ directly (bypassing the shared Dio client, since
  /// that client depends on this provider for its base URL). Returns null on
  /// success, or a human-readable reason on failure.
  Future<String?> testConnection(String address) async {
    final normalized = _normalize(address);
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    try {
      final response = await dio.get('$normalized/api/healthz/');
      if (response.statusCode == 200 || response.statusCode == 503) {
        return null;
      }
      return 'Server responded with ${response.statusCode}.';
    } on DioException catch (e) {
      return e.message ?? 'Could not reach server.';
    }
  }
}

final serverConfigProvider =
    AsyncNotifierProvider<ServerConfigController, String?>(
      ServerConfigController.new,
    );
