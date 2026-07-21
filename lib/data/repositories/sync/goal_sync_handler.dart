import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../local/database.dart';
import '../../local/sync_wire.dart';
import '../../local/tables/goals_table.dart';
import '../../local/tables/sync_columns.dart';
import 'sync_type_handler.dart';

class GoalSyncHandler implements SyncTypeHandler {
  GoalSyncHandler(this._db);

  final AppDatabase _db;

  @override
  String get typeName => 'goal';

  String _dateOnly(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  Map<String, dynamic> _toWire(Goal row) {
    return {
      'id': row.id,
      'local_rev': row.localRev,
      if (row.serverRev != null) 'base_server_rev': row.serverRev,
      'sync_state': syncStateToWire(SyncState.synced),
      'source': row.source.name,
      if (row.deletedAt != null)
        'deleted_at': row.deletedAt!.toUtc().toIso8601String(),
      'metric_type': healthMetricTypeToWire(row.metricType),
      'target_value': row.targetValue,
      'period': row.period.name,
      'start_date': _dateOnly(row.startDate),
      if (row.endDate != null) 'end_date': _dateOnly(row.endDate!),
      'is_active': row.isActive,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pendingWireRecords() async {
    final rows =
        await (_db.select(_db.goals)..where(
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
    // Accepted rows become synced only when download supplies server_rev.
    for (final id in conflicts) {
      await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
        const GoalsCompanion(syncState: Value(SyncState.conflict)),
      );
    }
    for (final entry in rejected) {
      final id = entry['id'] as String?;
      if (id == null) continue;
      await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
        const GoalsCompanion(syncState: Value(SyncState.failed)),
      );
    }
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
      const GoalsCompanion(syncState: Value(SyncState.synced)),
    );
  }

  @override
  Future<void> upsertDownloaded(
    Map<String, dynamic> json, {
    required bool forceOverwriteConflicts,
  }) async {
    if (!forceOverwriteConflicts) {
      final existing = await (_db.select(
        _db.goals,
      )..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
      if (existing?.syncState == SyncState.conflict) return;
    }

    await _db
        .into(_db.goals)
        .insertOnConflictUpdate(
          GoalsCompanion(
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
            metricType: Value(
              healthMetricTypeFromWire(json['metric_type'] as String),
            ),
            targetValue: Value((json['target_value'] as num).toDouble()),
            period: Value(GoalPeriod.values.byName(json['period'] as String)),
            startDate: Value(DateTime.parse(json['start_date'] as String)),
            endDate: Value(
              json['end_date'] == null
                  ? null
                  : DateTime.parse(json['end_date'] as String),
            ),
            isActive: Value(json['is_active'] as bool? ?? true),
          ),
        );
  }

  @override
  Future<SyncTypeCounts> counts() async {
    final t = _db.goals;
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
      _db.goals,
    )..where((t) => t.syncState.equalsValue(SyncState.conflict))).get();
    return rows
        .map(
          (r) => ConflictSummary(
            typeName: typeName,
            id: r.id,
            title: '${r.metricType.name} goal: ${r.targetValue}',
            subtitle: '${r.period.name} · starts ${_dateOnly(r.startDate)}',
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> wireForForceOverwrite(String id) async {
    final row = await (_db.select(
      _db.goals,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toWire(row)..remove('base_server_rev');
  }
}
