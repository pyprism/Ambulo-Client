import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Server-side import formats — large archives that need async, worker-side
/// parsing rather than client-side parsing. Wire values match the server's
/// `utils.enums.ImportFormat` exactly.
enum ServerImportFormat {
  googleTakeout,
  googleTakeoutSemantic,
  googleFit,
  tcx,
  ownTracksCsv,
}

extension ServerImportFormatX on ServerImportFormat {
  String get wireValue => switch (this) {
    ServerImportFormat.googleTakeout => 'google_takeout',
    ServerImportFormat.googleTakeoutSemantic => 'google_takeout_semantic',
    ServerImportFormat.googleFit => 'google_fit',
    ServerImportFormat.tcx => 'tcx',
    ServerImportFormat.ownTracksCsv => 'owntracks_csv',
  };

  String get label => switch (this) {
    ServerImportFormat.googleTakeout => 'Google Takeout (locations.json)',
    ServerImportFormat.googleTakeoutSemantic =>
      'Google Takeout (Semantic Location History)',
    ServerImportFormat.googleFit => 'Google Fit (steps CSV)',
    ServerImportFormat.tcx => 'TCX (workout export)',
    ServerImportFormat.ownTracksCsv => 'OwnTracks CSV',
  };
}

class ImportJobStatus {
  ImportJobStatus({
    required this.id,
    required this.status,
    required this.summary,
    required this.errorMessage,
  });

  factory ImportJobStatus.fromJson(Map<String, dynamic> json) {
    return ImportJobStatus(
      id: json['id'] as String,
      status: json['status'] as String,
      summary: (json['summary'] as Map?)?.cast<String, dynamic>() ?? const {},
      errorMessage: json['error_message'] as String? ?? '',
    );
  }

  final String id;
  final String status;
  final Map<String, dynamic> summary;
  final String errorMessage;

  bool get isPreviewReady => status == 'preview_ready';
  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
}

/// Uploads a large archive to the server for async parsing (Celery worker).
/// Requires the user to be signed in against a server — there is no
/// local-only equivalent, unlike the client-side `ImportRepository` formats.
class ServerImportRepository {
  ServerImportRepository(this._dio);

  final Dio _dio;

  Future<ImportJobStatus> upload({
    required ServerImportFormat format,
    required Uint8List bytes,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'source_format': format.wireValue,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post('/api/imports/', data: formData);
    return ImportJobStatus.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ImportJobStatus> status(String jobId) async {
    final response = await _dio.get('/api/imports/$jobId/');
    return ImportJobStatus.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ImportJobStatus> commit(String jobId) async {
    final response = await _dio.post('/api/imports/$jobId/commit/');
    return ImportJobStatus.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> revert(String jobId) async {
    await _dio.post('/api/imports/$jobId/revert/');
  }
}
