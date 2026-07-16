import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/sync_mutation.dart';
import '../local/tables/places_table.dart';
import '../local/tables/sync_columns.dart';

class PlaceRepository {
  PlaceRepository(this._db);

  final AppDatabase _db;

  Future<List<Place>> activePlaces() {
    return (_db.select(_db.places)..where((t) => t.deletedAt.isNull())).get();
  }

  Future<void> addPlace({
    required String name,
    required PlaceCategory category,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    String address = '',
  }) async {
    await _db
        .into(_db.places)
        .insert(
          PlacesCompanion.insert(
            name: name,
            category: Value(category),
            latitude: latitude,
            longitude: longitude,
            radiusMeters: Value(radiusMeters),
            address: Value(address),
            source: RecordSource.manual,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
  }

  Future<void> updatePlace(
    String id, {
    String? name,
    PlaceCategory? category,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? address,
  }) async {
    final current = await (_db.select(
      _db.places,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(_db.places)..where((t) => t.id.equals(id))).write(
      PlacesCompanion(
        name: name == null ? const Value.absent() : Value(name),
        category: category == null ? const Value.absent() : Value(category),
        latitude: latitude == null ? const Value.absent() : Value(latitude),
        longitude: longitude == null ? const Value.absent() : Value(longitude),
        radiusMeters: radiusMeters == null
            ? const Value.absent()
            : Value(radiusMeters),
        address: address == null ? const Value.absent() : Value(address),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }

  Future<void> deletePlace(String id) async {
    final current = await (_db.select(
      _db.places,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(_db.places)..where((t) => t.id.equals(id))).write(
      PlacesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }
}
