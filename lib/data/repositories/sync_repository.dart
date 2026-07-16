import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local/database.dart';
import 'sync/activity_sample_sync_handler.dart';
import 'sync/goal_sync_handler.dart';
import 'sync/health_sample_sync_handler.dart';
import 'sync/location_point_sync_handler.dart';
import 'sync/note_sync_handler.dart';
import 'sync/place_sync_handler.dart';
import 'sync/sync_type_handler.dart';
import 'sync/trip_sync_handler.dart';
import 'sync/workout_session_sync_handler.dart';

export 'sync/sync_type_handler.dart' show ConflictSummary;

class SyncCounts {
  const SyncCounts({
    required this.pending,
    required this.failed,
    required this.conflicts,
    required this.lastSyncAt,
  });

  final int pending;
  final int failed;
  final int conflicts;
  final DateTime? lastSyncAt;
}

/// Generic sync engine over every registered syncable type. Each concrete
/// [SyncTypeHandler] owns its table's wire shape; this class owns the
/// algorithm — one batched upload across all types, one changed-since
/// download loop across all types, conflict protection, and conflict
/// resolution — once, not copy-pasted per type.
class SyncRepository {
  SyncRepository(AppDatabase db, this._dio)
    : _handlers = [
        LocationPointSyncHandler(db),
        HealthSampleSyncHandler(db),
        ActivitySampleSyncHandler(db),
        GoalSyncHandler(db),
        PlaceSyncHandler(db),
        TripSyncHandler(db),
        WorkoutSessionSyncHandler(db),
        NoteSyncHandler(db),
      ];

  final List<SyncTypeHandler> _handlers;
  final Dio _dio;

  static const _cursorKeyPrefix = 'sync_cursor_';
  static const _lastSyncKey = 'sync_last_sync_at';
  static const _downloadBatchGuard = 50;

  Future<int> _cursor(String typeName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_cursorKeyPrefix$typeName') ?? 0;
  }

  Future<void> _saveCursor(String typeName, int cursor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_cursorKeyPrefix$typeName', cursor);
  }

  Future<DateTime?> lastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> _saveLastSyncAt(DateTime at) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, at.toIso8601String());
  }

  Future<SyncCounts> counts() async {
    var total = SyncTypeCounts.zero;
    for (final handler in _handlers) {
      total += await handler.counts();
    }
    return SyncCounts(
      pending: total.pending,
      failed: total.failed,
      conflicts: total.conflicts,
      lastSyncAt: await lastSyncAt(),
    );
  }

  Future<List<ConflictSummary>> allConflicts() async {
    final all = <ConflictSummary>[];
    for (final handler in _handlers) {
      all.addAll(await handler.conflictSummaries());
    }
    return all;
  }

  Future<void> _uploadAll() async {
    final recordsByType = <String, List<Map<String, dynamic>>>{};
    for (final handler in _handlers) {
      final pending = await handler.pendingWireRecords();
      if (pending.isNotEmpty) recordsByType[handler.typeName] = pending;
    }
    if (recordsByType.isEmpty) return;

    final response = await _dio.post(
      '/api/sync/upload/',
      data: {'records': recordsByType},
    );
    final data = response.data as Map<String, dynamic>;
    for (final handler in _handlers) {
      final bucket = data[handler.typeName] as Map<String, dynamic>?;
      if (bucket == null) continue;
      await handler.applyUploadResult(
        accepted: (bucket['accepted'] as List).cast<String>(),
        conflicts: (bucket['conflicts'] as List).cast<String>(),
        rejected: (bucket['rejected'] as List).cast<Map<String, dynamic>>(),
      );
    }
  }

  /// One `/sync/download` request covers every type's cursor at once (the
  /// server always returns all registered types regardless of which cursors
  /// are passed), looping while any type still has more to fetch.
  Future<void> _downloadAll({
    bool forceOverwriteConflicts = false,
    Iterable<SyncTypeHandler>? only,
  }) async {
    final targets = (only ?? _handlers).toList();
    if (targets.isEmpty) return;

    for (var i = 0; i < _downloadBatchGuard; i++) {
      final cursors = {
        for (final handler in targets)
          handler.typeName: await _cursor(handler.typeName),
      };
      final response = await _dio.get(
        '/api/sync/download/',
        queryParameters: cursors,
      );
      final data = response.data as Map<String, dynamic>;

      var anyMore = false;
      for (final handler in targets) {
        final bucket = data[handler.typeName] as Map<String, dynamic>?;
        if (bucket == null) continue;
        final records = (bucket['records'] as List)
            .cast<Map<String, dynamic>>();
        for (final record in records) {
          await handler.upsertDownloaded(
            record,
            forceOverwriteConflicts: forceOverwriteConflicts,
          );
        }
        final newCursor = bucket['cursor'] as int;
        await _saveCursor(handler.typeName, newCursor);
        if (bucket['has_more'] == true) anyMore = true;
      }
      if (!anyMore) break;
    }
  }

  /// Upload-then-download: uploading first means the download pass (which
  /// reads changed-since our cursor) also pulls back our own just-uploaded
  /// rows with their authoritative server_rev, reconciling in one pass.
  Future<SyncCounts> syncNow() async {
    await _uploadAll();
    await _downloadAll();
    await _saveLastSyncAt(DateTime.now());
    return counts();
  }

  /// Resolve one conflict by force-overwriting the server with our local
  /// copy — omitting `base_server_rev` skips the server's conflict check
  /// entirely, so this always wins.
  Future<void> resolveKeepMine(String typeName, String id) async {
    final handler = _handlers.firstWhere((h) => h.typeName == typeName);
    final wire = await handler.wireForForceOverwrite(id);
    final response = await _dio.post(
      '/api/sync/upload/',
      data: {
        'records': {
          typeName: [wire],
        },
      },
    );
    final data = response.data as Map<String, dynamic>;
    final bucket = data[typeName] as Map<String, dynamic>;
    final accepted = (bucket['accepted'] as List).cast<String>();
    if (accepted.contains(id)) {
      await handler.markSynced(id);
    }
    await _downloadAll(only: [handler]);
  }

  /// Resolve all outstanding conflicts for one record type by discarding
  /// local edits and re-pulling the server's version of everything since the
  /// start for that type — simple and correct, though heavier than resolving
  /// one record at a time. The one path allowed to overwrite conflict rows.
  Future<void> resolveAllTakeTheirs(String typeName) async {
    final handler = _handlers.firstWhere((h) => h.typeName == typeName);
    await _saveCursor(typeName, 0);
    await _downloadAll(forceOverwriteConflicts: true, only: [handler]);
  }

  /// Resets every type's download cursor to 0 — pairs with
  /// `AppDatabase.wipeAllLocalData()` so a local wipe is actually
  /// recoverable: without this, the next sync would only pull records
  /// changed *after* the old cursor, and everything that was already
  /// synced away before the wipe would never come back even though it
  /// still exists server-side.
  Future<void> resetAllCursorsForRewipe() async {
    for (final handler in _handlers) {
      await _saveCursor(handler.typeName, 0);
    }
  }
}
