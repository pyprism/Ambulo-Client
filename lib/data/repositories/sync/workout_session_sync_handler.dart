import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../local/database.dart';
import '../../local/sync_wire.dart';
import '../../local/tables/activity_samples_table.dart';
import '../../local/tables/sync_columns.dart';
import 'sync_type_handler.dart';

class WorkoutSessionSyncHandler implements SyncTypeHandler {
  WorkoutSessionSyncHandler(this._db);

  final AppDatabase _db;

  @override
  String get typeName => 'workout_session';

  Map<String, dynamic> _toWire(WorkoutSession row) {
    return {
      'id': row.id,
      'local_rev': row.localRev,
      if (row.serverRev != null) 'base_server_rev': row.serverRev,
      'sync_state': syncStateToWire(SyncState.synced),
      'source': row.source.name,
      if (row.deletedAt != null)
        'deleted_at': row.deletedAt!.toUtc().toIso8601String(),
      'activity_type': row.activityType.name,
      'started_at': row.startedAt.toUtc().toIso8601String(),
      if (row.endedAt != null)
        'ended_at': row.endedAt!.toUtc().toIso8601String(),
      'distance_meters': row.distanceMeters,
      'calories': row.calories,
      'notes': row.notes,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pendingWireRecords() async {
    final rows =
        await (_db.select(_db.workoutSessions)..where(
              (t) =>
                  t.syncState.equalsValue(SyncState.pendingUpload) |
                  t.syncState.equalsValue(SyncState.failed),
            ))
            .get();
    return rows.map(_toWire).toList();
  }

  @override
  Future<void> applyUploadResult({
    required List<String> accepted,
    required List<String> conflicts,
    required List<Map<String, dynamic>> rejected,
  }) async {
    for (final id in accepted) {
      await markSynced(id);
    }
    for (final id in conflicts) {
      await (_db.update(
        _db.workoutSessions,
      )..where((t) => t.id.equals(id))).write(
        const WorkoutSessionsCompanion(syncState: Value(SyncState.conflict)),
      );
    }
    for (final entry in rejected) {
      final id = entry['id'] as String?;
      if (id == null) continue;
      await (_db.update(
        _db.workoutSessions,
      )..where((t) => t.id.equals(id))).write(
        const WorkoutSessionsCompanion(syncState: Value(SyncState.failed)),
      );
    }
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(
      _db.workoutSessions,
    )..where((t) => t.id.equals(id))).write(
      const WorkoutSessionsCompanion(syncState: Value(SyncState.synced)),
    );
  }

  @override
  Future<void> upsertDownloaded(
    Map<String, dynamic> json, {
    required bool forceOverwriteConflicts,
  }) async {
    if (!forceOverwriteConflicts) {
      final existing = await (_db.select(
        _db.workoutSessions,
      )..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
      if (existing?.syncState == SyncState.conflict) return;
    }

    await _db
        .into(_db.workoutSessions)
        .insertOnConflictUpdate(
          WorkoutSessionsCompanion(
            id: Value(json['id'] as String),
            localRev: Value(json['local_rev'] as int? ?? 0),
            serverRev: Value(json['server_rev'] as int?),
            syncState: Value(syncStateFromWire(json['sync_state'] as String)),
            source: Value(RecordSource.values.byName(json['source'] as String)),
            createdAt: Value(DateTime.parse(json['created_at'] as String)),
            updatedAt: Value(DateTime.parse(json['updated_at'] as String)),
            deletedAt: Value(
              json['deleted_at'] == null
                  ? null
                  : DateTime.parse(json['deleted_at'] as String),
            ),
            activityType: Value(
              ActivityType.values.byName(json['activity_type'] as String),
            ),
            startedAt: Value(DateTime.parse(json['started_at'] as String)),
            endedAt: Value(
              json['ended_at'] == null
                  ? null
                  : DateTime.parse(json['ended_at'] as String),
            ),
            distanceMeters: Value(
              (json['distance_meters'] as num?)?.toDouble(),
            ),
            calories: Value((json['calories'] as num?)?.toDouble()),
            notes: Value(json['notes'] as String? ?? ''),
          ),
        );
  }

  @override
  Future<SyncTypeCounts> counts() async {
    final t = _db.workoutSessions;
    final pendingCount = countAll(
      filter:
          t.syncState.equalsValue(SyncState.pendingUpload) |
          t.syncState.equalsValue(SyncState.localOnly),
    );
    final failedCount = countAll(
      filter: t.syncState.equalsValue(SyncState.failed),
    );
    final conflictCount = countAll(
      filter: t.syncState.equalsValue(SyncState.conflict),
    );
    final row = await (_db.selectOnly(
      t,
    )..addColumns([pendingCount, failedCount, conflictCount])).getSingle();
    return SyncTypeCounts(
      pending: row.read(pendingCount) ?? 0,
      failed: row.read(failedCount) ?? 0,
      conflicts: row.read(conflictCount) ?? 0,
    );
  }

  @override
  Future<List<ConflictSummary>> conflictSummaries() async {
    final rows = await (_db.select(
      _db.workoutSessions,
    )..where((t) => t.syncState.equalsValue(SyncState.conflict))).get();
    return rows
        .map(
          (r) => ConflictSummary(
            typeName: typeName,
            id: r.id,
            title: '${r.activityType.name} workout',
            subtitle: DateFormat.yMMMd().add_jm().format(r.startedAt.toLocal()),
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> wireForForceOverwrite(String id) async {
    final row = await (_db.select(
      _db.workoutSessions,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toWire(row)..remove('base_server_rev');
  }
}
