import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/sync_mutation.dart';

class TripRepository {
  TripRepository(this._db);

  final AppDatabase _db;

  /// Rename only — start/end/distance/points are GPS-derived, not
  /// something to hand-edit.
  Future<void> updateTrip(String id, {required String name}) async {
    final current = await (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(_db.trips)..where((t) => t.id.equals(id))).write(
      TripsCompanion(
        name: Value(name),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }

  Future<void> deleteTrip(String id) async {
    final current = await (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(_db.trips)..where((t) => t.id.equals(id))).write(
      TripsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }
}
