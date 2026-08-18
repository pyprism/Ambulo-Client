import 'package:drift/drift.dart';

import '../../../shared/format/app_date_format.dart';
import '../../local/database.dart';
import '../../local/sync_wire.dart';
import '../../local/tables/location_points_table.dart';
import '../../local/tables/sync_columns.dart';
import 'sync_type_handler.dart';

class LocationPointSyncHandler implements SyncTypeHandler {
  LocationPointSyncHandler(this._db);

  final AppDatabase _db;

  @override
  String get typeName => 'location_point';

  Map<String, dynamic> _toWire(LocationPoint row) {
    return {
      'id': row.id,
      'local_rev': row.localRev,
      if (row.serverRev != null) 'base_server_rev': row.serverRev,
      'sync_state': syncStateToWire(SyncState.synced),
      'source': row.source.name,
      if (row.deletedAt != null)
        'deleted_at': row.deletedAt!.toUtc().toIso8601String(),
      'latitude': row.latitude,
      'longitude': row.longitude,
      'altitude': row.altitude,
      'horizontal_accuracy': row.horizontalAccuracy,
      'vertical_accuracy': row.verticalAccuracy,
      'speed': row.speed,
      'speed_accuracy': row.speedAccuracy,
      'heading': row.heading,
      'recorded_at': row.recordedAt.toUtc().toIso8601String(),
      'battery_level': row.batteryLevel,
      'connectivity': row.connectivity.name,
      'monitoring_mode': row.monitoringMode.name,
      'trip_id': row.tripId,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pendingWireRecords() async {
    final rows =
        await (_db.select(_db.locationPoints)..where(
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
    // The upload response has no authoritative server revision. Keep accepted
    // rows pending until the following download stores that revision; retrying
    // the client UUID is idempotent and preserves conflict protection.
    for (final id in conflicts) {
      await (_db.update(
        _db.locationPoints,
      )..where((t) => t.id.equals(id))).write(
        const LocationPointsCompanion(syncState: Value(SyncState.conflict)),
      );
    }
    for (final entry in rejected) {
      final id = entry['id'] as String?;
      if (id == null) continue;
      await (_db.update(
        _db.locationPoints,
      )..where((t) => t.id.equals(id))).write(
        const LocationPointsCompanion(syncState: Value(SyncState.failed)),
      );
    }
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(_db.locationPoints)..where((t) => t.id.equals(id))).write(
      const LocationPointsCompanion(syncState: Value(SyncState.synced)),
    );
  }

  @override
  Future<void> upsertDownloaded(
    Map<String, dynamic> json, {
    required bool forceOverwriteConflicts,
    Set<String>? allowedConflictIds,
  }) async {
    final id = json['id'] as String;
    final existing = await (_db.select(
      _db.locationPoints,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    final canOverwriteConflict =
        forceOverwriteConflicts &&
        (allowedConflictIds == null || allowedConflictIds.contains(id));
    if (!canOverwriteConflict && existing?.syncState == SyncState.conflict) {
      return;
    }
    // A row edited locally after this record's upload snapshot was taken
    // (still pendingUpload, but localRev has moved on) must not be rewound
    // by applying that stale snapshot back from download.
    if (existing != null &&
        existing.localRev > (json['local_rev'] as int? ?? 0)) {
      await _adoptServerRevOnly(id, existing, json);
      return;
    }

    await _db
        .into(_db.locationPoints)
        .insertOnConflictUpdate(
          LocationPointsCompanion(
            id: Value(id),
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
            deviceId: Value(json['device'] as String?),
            latitude: Value((json['latitude'] as num).toDouble()),
            longitude: Value((json['longitude'] as num).toDouble()),
            altitude: Value((json['altitude'] as num?)?.toDouble()),
            horizontalAccuracy: Value(
              (json['horizontal_accuracy'] as num?)?.toDouble(),
            ),
            verticalAccuracy: Value(
              (json['vertical_accuracy'] as num?)?.toDouble(),
            ),
            speed: Value((json['speed'] as num?)?.toDouble()),
            speedAccuracy: json.containsKey('speed_accuracy')
                ? Value((json['speed_accuracy'] as num?)?.toDouble())
                : const Value.absent(),
            heading: Value((json['heading'] as num?)?.toDouble()),
            recordedAt: Value(DateTime.parse(json['recorded_at'] as String)),
            batteryLevel: Value(json['battery_level'] as int?),
            connectivity: Value(
              Connectivity.values.byName(json['connectivity'] as String),
            ),
            monitoringMode: Value(
              MonitoringMode.values.byName(json['monitoring_mode'] as String),
            ),
            tripId: json.containsKey('trip_id')
                ? Value(json['trip_id'] as String?)
                : const Value.absent(),
          ),
        );
  }

  /// A row whose local edit is newer than this download's snapshot skips
  /// the data update above — but the server_rev the server just assigned
  /// must still land locally, or this row's cached server_rev goes stale
  /// and the *next* upload's base_server_rev mismatches the server's real
  /// value, misreporting a conflict against nobody but this client's own
  /// prior sync.
  Future<void> _adoptServerRevOnly(
    String id,
    LocationPoint existing,
    Map<String, dynamic> json,
  ) async {
    final serverRev = json['server_rev'] as int?;
    if (serverRev == null || serverRev == existing.serverRev) return;
    await (_db.update(_db.locationPoints)..where((t) => t.id.equals(id))).write(
      LocationPointsCompanion(serverRev: Value(serverRev)),
    );
  }

  @override
  Future<SyncTypeCounts> counts() async {
    final t = _db.locationPoints;
    // localOnly rows are never picked up by pendingWireRecords() (only
    // pendingUpload/failed are), so counting them as "pending" showed a
    // permanent nonzero count that "Sync now" could never drain.
    final pendingCount = countAll(
      filter: t.syncState.equalsValue(SyncState.pendingUpload),
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
      _db.locationPoints,
    )..where((t) => t.syncState.equalsValue(SyncState.conflict))).get();
    return rows
        .map(
          (r) => ConflictSummary(
            typeName: typeName,
            id: r.id,
            title:
                '${r.latitude.toStringAsFixed(5)}, ${r.longitude.toStringAsFixed(5)}',
            subtitle: AppDateFormat.dateTime(r.recordedAt.toLocal()),
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> wireForForceOverwrite(String id) async {
    final row = await (_db.select(
      _db.locationPoints,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toWire(row)..remove('base_server_rev');
  }
}
