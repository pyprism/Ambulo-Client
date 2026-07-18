import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/secure_token_storage.dart';
import '../../data/repositories/device_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../server/server_config_controller.dart';

/// The shared, authenticated Dio client. Attaches the access token to every
/// request and transparently refreshes it once on a 401 (single-flight, so
/// concurrent requests don't each trigger their own refresh call).
final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(serverConfigProvider).value ?? '';
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    _AuthInterceptor(
      ref,
      baseUrl,
      ref.watch(tokenStorageProvider),
      ref.watch(deviceRepositoryProvider),
    ),
  );
  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(
    this._ref,
    this._baseUrl,
    this._tokenStorage,
    this._deviceRepository,
  );

  final Ref _ref;
  final String _baseUrl;
  final TokenStorage _tokenStorage;
  final DeviceRepository _deviceRepository;
  Future<bool>? _refreshInFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Multi-device by default (locked decision): every syncable record
    // needs a device id, and `utils/etc.py:resolve_device` on the server
    // reads it from this header, not the request body.
    final device = await _deviceRepository.ensureLocalDevice();
    options.headers['X-Device-ID'] = device.id;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await _refresh();
    if (!refreshed) {
      await _tokenStorage.clear();
      unawaited(_ref.read(authControllerProvider.notifier).handleSignedOut());
      handler.next(err);
      return;
    }

    try {
      final retryDio = Dio(BaseOptions(baseUrl: _baseUrl));
      final token = await _tokenStorage.readAccessToken();
      final options = err.requestOptions;
      options.extra['retried'] = true;
      options.headers['Authorization'] = 'Bearer $token';
      final response = await retryDio.fetch(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return false;
    try {
      final dio = Dio(BaseOptions(baseUrl: _baseUrl));
      final response = await dio.post(
        '/api/token/refresh/',
        data: {'refresh': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final newAccess = data['access'] as String;
      final newRefresh = data['refresh'] as String?;
      if (newRefresh != null) {
        await _tokenStorage.saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh,
        );
      } else {
        await _tokenStorage.saveAccessToken(newAccess);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Extracts a human-readable message from a failed DioException response.
///
/// The server's error shape (utils.exceptions.custom_exception_handler) is
/// `{"message": "<summary>", "errors": {"<field>": ["<detail>", ...], ...}}`
/// — `errors` is the actually-useful part (every field, every validator
/// message; e.g. several failed password rules at once), `message` is just
/// a generic one-line summary. Prefer `errors`; only fall back to `message`
/// alone if there's nothing more specific.
String describeDioError(DioException error) {
  final data = error.response?.data;
  if (data is Map) {
    final errors = data['errors'];
    if (errors != null) {
      final lines = _flattenErrorDetail(errors, '');
      if (lines.isNotEmpty) return lines.join('\n');
    }

    final message = data['message'];
    if (message is String) return message;

    // Defensive fallback for any response that doesn't follow the
    // {message, errors} shape at all.
    final lines = _flattenErrorDetail(data, '');
    if (lines.isNotEmpty) return lines.join('\n');
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return 'Could not reach the server. Check the address and your connection.';
  }
  return error.message ?? 'Something went wrong.';
}

const _unlabelledErrorKeys = {'non_field_errors', 'detail'};

/// Walks a (possibly nested) DRF error-detail structure into one line per
/// leaf message, prefixed with its field path where that's meaningful.
List<String> _flattenErrorDetail(dynamic node, String path) {
  final lines = <String>[];
  if (node is Map) {
    for (final entry in node.entries) {
      final key = entry.key.toString();
      final nextPath = path.isEmpty ? key : '$path.$key';
      lines.addAll(_flattenErrorDetail(entry.value, nextPath));
    }
  } else if (node is List) {
    for (var i = 0; i < node.length; i++) {
      final item = node[i];
      lines.addAll(
        item is Map || item is List
            ? _flattenErrorDetail(item, '$path[$i]')
            : _flattenErrorDetail(item, path),
      );
    }
  } else if (node != null) {
    final lastSegment = path.split('.').last.split('[').first;
    final labelled =
        path.isNotEmpty && !_unlabelledErrorKeys.contains(lastSegment);
    lines.add(labelled ? '$path: $node' : node.toString());
  }
  return lines;
}
