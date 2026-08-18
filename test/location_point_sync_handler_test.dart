import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/data/repositories/sync/location_point_sync_handler.dart';

Map<String, dynamic> _wire({
  required String id,
  required int localRev,
  required int serverRev,
  double latitude = 1,
  double longitude = 1,
}) => {
  'id': id,
  'local_rev': localRev,
  'server_rev': serverRev,
  'sync_state': 'synced',
  'source': 'location',
  'created_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
  'updated_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
  'deleted_at': null,
  'device': null,
  'latitude': latitude,
  'longitude': longitude,
  'altitude': null,
  'horizontal_accuracy': null,
  'vertical_accuracy': null,
  'speed': null,
  'speed_accuracy': null,
  'heading': null,
  'recorded_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
  'battery_level': null,
  'connectivity': 'unknown',
  'monitoring_mode': 'manual',
  'trip_id': null,
};

void main() {
  late AppDatabase db;
  late LocationPointSyncHandler handler;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    handler = LocationPointSyncHandler(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('a download response older than a since-made local edit still adopts '
      'the server_rev it carries, without rewinding the edited data — so the '
      'next upload sends a base_server_rev that matches the server and is '
      'not misreported as a conflict', () async {
    const id = 'a5f2e6d0-0000-4000-8000-000000000001';

    // Row already synced once: local_rev 1, server_rev 100.
    await handler.upsertDownloaded(
      _wire(id: id, localRev: 1, serverRev: 100),
      forceOverwriteConflicts: false,
    );

    // The user edits the point locally (e.g. a correction) after that —
    // bumped to local_rev 2, still pendingUpload, new coordinates.
    await (db.update(db.locationPoints)..where((t) => t.id.equals(id))).write(
      const LocationPointsCompanion(
        latitude: Value(55.0),
        localRev: Value(2),
        syncState: Value(SyncState.pendingUpload),
      ),
    );

    // A download response arrives carrying the *old* snapshot (local_rev
    // 1) but the server_rev this client's own prior upload was just
    // assigned (200) — simulating the response racing the local edit.
    await handler.upsertDownloaded(
      _wire(id: id, localRev: 1, serverRev: 200, latitude: 1),
      forceOverwriteConflicts: false,
    );

    final row = await (db.select(
      db.locationPoints,
    )..where((t) => t.id.equals(id))).getSingle();

    // Data and local_rev untouched — the newer local edit survives.
    expect(row.latitude, 55.0);
    expect(row.localRev, 2);
    expect(row.syncState, SyncState.pendingUpload);
    // But server_rev *is* adopted — otherwise the next upload's
    // base_server_rev (still 100) would mismatch the server's real
    // current value (200) and come back flagged as a conflict, even
    // though nothing but this client ever touched the record.
    expect(row.serverRev, 200);
  });
}
