import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/activity_samples_table.dart';
import 'tables/devices_table.dart';
import 'tables/goals_table.dart';
import 'tables/health_samples_table.dart';
import 'tables/location_points_table.dart';
import 'tables/notes_table.dart';
import 'tables/places_table.dart';
import 'tables/sync_columns.dart';
import 'tables/trips_table.dart';
import 'tables/workout_sessions_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Devices,
    LocationPoints,
    HealthSamples,
    ActivitySamples,
    Goals,
    Places,
    Trips,
    WorkoutSessions,
    Notes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(healthSamples);
        await m.createTable(activitySamples);
        await m.createTable(goals);
      }
      if (from < 3) {
        await m.createTable(places);
        await m.createTable(trips);
      }
      if (from < 4) {
        await m.createTable(workoutSessions);
        await m.createTable(notes);
        await m.createIndex(idxLocationPointsHistory);
        await m.createIndex(idxLocationPointsSyncState);
        await m.createIndex(idxHealthSamplesMetricRecorded);
        await m.createIndex(idxHealthSamplesSyncState);
        await m.createIndex(idxActivitySamplesSyncState);
        await m.createIndex(idxPlacesDeletedAt);
      }
    },
  );

  /// Hard-deletes every locally-stored record (location/health/activity
  /// history, goals, places, trips) on this device. Deliberately doesn't
  /// touch `Devices` (still needed for sync identity) and doesn't tombstone
  /// or propagate to the server — data already synced elsewhere is
  /// untouched, this is a local wipe, not an account-wide delete.
  Future<void> wipeAllLocalData() async {
    await transaction(() async {
      await delete(locationPoints).go();
      await delete(healthSamples).go();
      await delete(activitySamples).go();
      await delete(goals).go();
      await delete(places).go();
      await delete(trips).go();
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'ambulo',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
