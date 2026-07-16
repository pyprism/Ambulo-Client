import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// The four monitoring modes. Quit is the default.
/// Mirrors server `utils.enums.MonitoringMode`.
enum MonitoringMode { quit, manual, significant, move }

/// Mirrors server `utils.enums.Connectivity`.
enum Connectivity { wifi, cellular, offline, unknown }

// Unbounded, continuously-growing table (every tracked point ever
// recorded) — the map/timeline's "latest history" query and the sync
// engine's pending/failed/conflict counts both scan it on every screen
// visit and every sync, so both need an index before the row count gets
// large enough for a full table scan to matter.
@TableIndex(
  name: 'idx_location_points_history',
  columns: {#deletedAt, #recordedAt},
)
@TableIndex(name: 'idx_location_points_sync_state', columns: {#syncState})
class LocationPoints extends Table with SyncableColumns {
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get horizontalAccuracy => real().nullable()();
  RealColumn get verticalAccuracy => real().nullable()();
  RealColumn get speed => real().nullable()();
  RealColumn get heading => real().nullable()();

  DateTimeColumn get recordedAt => dateTime()();

  IntColumn get batteryLevel => integer().nullable()();
  TextColumn get connectivity =>
      textEnum<Connectivity>().withDefault(const Constant('unknown'))();
  TextColumn get monitoringMode => textEnum<MonitoringMode>()();
}
