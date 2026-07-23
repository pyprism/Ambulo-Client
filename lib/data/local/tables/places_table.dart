import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// Mirrors server `utils.enums.PlaceCategory`.
enum PlaceCategory { home, work, gym, travel, custom }

/// User-defined region / geofence. `currentlyInside`/`lastEnteredAt`/
/// `lastExitedAt` are computed locally for offline-first responsiveness, but
/// are read-only on the server — once synced, the server's own geofence
/// processing is authoritative and overwrites these on download.
// Every location update runs `GeofenceService.checkTransitions`, which
// scans "active" (not deleted) places on each call.
@TableIndex(name: 'idx_places_deleted_at', columns: {#deletedAt})
class Places extends Table with SyncableColumns {
  TextColumn get name => text()();
  TextColumn get category =>
      textEnum<PlaceCategory>().withDefault(const Constant('custom'))();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get radiusMeters => real().withDefault(const Constant(100))();
  TextColumn get address => text().withDefault(const Constant(''))();
  BoolColumn get currentlyInside =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastEnteredAt => dateTime().nullable()();
  DateTimeColumn get lastExitedAt => dateTime().nullable()();
  DateTimeColumn get stateAsOf => dateTime().nullable()();
  BoolColumn get notifyFriends =>
      boolean().withDefault(const Constant(false))();
}
