import 'package:drift/drift.dart';

import '../../../shared/format/app_date_format.dart';
import '../../local/database.dart';
import '../../local/sync_wire.dart';
import '../../local/tables/places_table.dart';
import '../../local/tables/sync_columns.dart';
import 'sync_type_handler.dart';

class PlaceSyncHandler implements SyncTypeHandler {
  PlaceSyncHandler(this._db);

  final AppDatabase _db;

  @override
  String get typeName => 'place';

  Map<String, dynamic> _toWire(Place row) {
    return {
      'id': row.id,
      'local_rev': row.localRev,
      if (row.serverRev != null) 'base_server_rev': row.serverRev,
      'sync_state': syncStateToWire(SyncState.synced),
      'source': row.source.name,
      if (row.deletedAt != null)
        'deleted_at': row.deletedAt!.toUtc().toIso8601String(),
      'name': row.name,
      'category': row.category.name,
      'latitude': row.latitude,
      'longitude': row.longitude,
      'radius_meters': row.radiusMeters,
      'address': row.address,
      'notify_friends': row.notifyFriends,
      // currently_inside/last_entered_at/last_exited_at are server
      // read-only — computed locally for offline responsiveness, but never
      // sent upstream.
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pendingWireRecords() async {
    final rows =
        await (_db.select(_db.places)..where(
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
      await (_db.update(_db.places)..where((t) => t.id.equals(id))).write(
        const PlacesCompanion(syncState: Value(SyncState.conflict)),
      );
    }
    for (final entry in rejected) {
      final id = entry['id'] as String?;
      if (id == null) continue;
      await (_db.update(_db.places)..where((t) => t.id.equals(id))).write(
        const PlacesCompanion(syncState: Value(SyncState.failed)),
      );
    }
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(_db.places)..where((t) => t.id.equals(id))).write(
      const PlacesCompanion(syncState: Value(SyncState.synced)),
    );
  }

  @override
  Future<void> upsertDownloaded(
    Map<String, dynamic> json, {
    required bool forceOverwriteConflicts,
  }) async {
    final existing = await (_db.select(
      _db.places,
    )..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
    if (!forceOverwriteConflicts && existing?.syncState == SyncState.conflict) {
      return;
    }

    // currentlyInside/lastEnteredAt/lastExitedAt are recomputed locally on
    // every location update by GeofenceService.checkTransitions — the server
    // keeps its own copy of the same fields (for devices that never track),
    // but on a device that's actively tracking, letting a download overwrite
    // them can briefly regress the local in/out state and re-trigger a
    // transition. Keep whatever is already on-device once a row exists;
    // only seed from the server payload the first time this place is seen.
    final currentlyInside = Value(
      existing?.currentlyInside ?? (json['currently_inside'] as bool? ?? false),
    );
    final lastEnteredAt = Value(
      existing != null
          ? existing.lastEnteredAt
          : (json['last_entered_at'] == null
                ? null
                : DateTime.parse(json['last_entered_at'] as String)),
    );
    final lastExitedAt = Value(
      existing != null
          ? existing.lastExitedAt
          : (json['last_exited_at'] == null
                ? null
                : DateTime.parse(json['last_exited_at'] as String)),
    );

    await _db
        .into(_db.places)
        .insertOnConflictUpdate(
          PlacesCompanion(
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
            name: Value(json['name'] as String),
            category: Value(
              PlaceCategory.values.byName(json['category'] as String),
            ),
            latitude: Value((json['latitude'] as num).toDouble()),
            longitude: Value((json['longitude'] as num).toDouble()),
            radiusMeters: Value((json['radius_meters'] as num).toDouble()),
            address: Value(json['address'] as String? ?? ''),
            notifyFriends: Value(json['notify_friends'] as bool? ?? false),
            currentlyInside: currentlyInside,
            lastEnteredAt: lastEnteredAt,
            lastExitedAt: lastExitedAt,
          ),
        );
  }

  @override
  Future<SyncTypeCounts> counts() async {
    final t = _db.places;
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
      _db.places,
    )..where((t) => t.syncState.equalsValue(SyncState.conflict))).get();
    return rows
        .map(
          (r) => ConflictSummary(
            typeName: typeName,
            id: r.id,
            title: r.name,
            subtitle: AppDateFormat.date(r.updatedAt.toLocal()),
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> wireForForceOverwrite(String id) async {
    final row = await (_db.select(
      _db.places,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toWire(row)..remove('base_server_rev');
  }
}
