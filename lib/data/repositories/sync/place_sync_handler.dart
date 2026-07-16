import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

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
      // currently_inside/last_entered_at/last_exited_at are server
      // read-only — computed locally for offline responsiveness, but never
      // sent upstream.
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pendingWireRecords() async {
    final all = await _db.select(_db.places).get();
    return all
        .where(
          (r) =>
              r.syncState == SyncState.pendingUpload ||
              r.syncState == SyncState.failed,
        )
        .map(_toWire)
        .toList();
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
    if (!forceOverwriteConflicts) {
      final existing = await (_db.select(
        _db.places,
      )..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
      if (existing?.syncState == SyncState.conflict) return;
    }

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
            currentlyInside: Value(json['currently_inside'] as bool? ?? false),
            lastEnteredAt: Value(
              json['last_entered_at'] == null
                  ? null
                  : DateTime.parse(json['last_entered_at'] as String),
            ),
            lastExitedAt: Value(
              json['last_exited_at'] == null
                  ? null
                  : DateTime.parse(json['last_exited_at'] as String),
            ),
          ),
        );
  }

  @override
  Future<SyncTypeCounts> counts() async {
    final rows = await _db.select(_db.places).get();
    return SyncTypeCounts(
      pending: rows
          .where(
            (r) =>
                r.syncState == SyncState.pendingUpload ||
                r.syncState == SyncState.localOnly,
          )
          .length,
      failed: rows.where((r) => r.syncState == SyncState.failed).length,
      conflicts: rows.where((r) => r.syncState == SyncState.conflict).length,
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
            subtitle: DateFormat.yMMMd().format(r.updatedAt.toLocal()),
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
