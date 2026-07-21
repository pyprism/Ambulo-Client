import 'package:drift/drift.dart';

import '../../data/local/database.dart';
import 'geo_math.dart';

/// Computes enter/leave transitions locally so they're visible immediately,
/// offline-first — `currently_inside`/`last_entered_at`/`last_exited_at` are
/// server read-only, so once synced the server's own geofence processing
/// takes over and this local guess is reconciled on the next download.
class GeofenceService {
  GeofenceService(this._db);

  final AppDatabase _db;

  Future<void> checkTransitions({
    required double latitude,
    required double longitude,
    required DateTime recordedAt,
  }) async {
    final places = await (_db.select(
      _db.places,
    )..where((t) => t.deletedAt.isNull())).get();

    for (final place in places) {
      // Guard against out-of-order points (batched uploads, GPS jitter)
      // clobbering a more recent state.
      if (place.stateAsOf != null && recordedAt.isBefore(place.stateAsOf!)) {
        continue;
      }

      final distance = haversineMeters(
        latitude,
        longitude,
        place.latitude,
        place.longitude,
      );
      final isInside = distance <= place.radiusMeters;
      if (isInside == place.currentlyInside) continue;

      await (_db.update(_db.places)..where((t) => t.id.equals(place.id))).write(
        PlacesCompanion(
          currentlyInside: Value(isInside),
          lastEnteredAt: isInside
              ? Value(recordedAt)
              : Value(place.lastEnteredAt),
          lastExitedAt: isInside
              ? Value(place.lastExitedAt)
              : Value(recordedAt),
          stateAsOf: Value(recordedAt),
        ),
      );
    }
  }
}
