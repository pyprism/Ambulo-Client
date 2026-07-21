import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/activity_samples_table.dart';
import 'package:ambulo/data/local/tables/health_samples_table.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';

void main() {
  test(
    'wipeAllLocalData clears tracked data but keeps device identity',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db
          .into(db.devices)
          .insert(
            DevicesCompanion.insert(
              id: 'device-1',
              name: 'Test device',
              platform: 'android',
            ),
          );
      await db
          .into(db.locationPoints)
          .insert(
            LocationPointsCompanion.insert(
              latitude: 1,
              longitude: 2,
              recordedAt: DateTime.now(),
              monitoringMode: MonitoringMode.manual,
              source: RecordSource.manual,
            ),
          );
      await db
          .into(db.healthSamples)
          .insert(
            HealthSamplesCompanion.insert(
              metricType: HealthMetricType.steps,
              value: 100,
              recordedAt: DateTime.now(),
              source: RecordSource.health,
            ),
          );
      await db
          .into(db.activitySamples)
          .insert(
            ActivitySamplesCompanion.insert(
              activityType: ActivityType.walking,
              startedAt: DateTime.now(),
              source: RecordSource.motion,
            ),
          );
      await db
          .into(db.goals)
          .insert(
            GoalsCompanion.insert(
              metricType: HealthMetricType.steps,
              targetValue: 10000,
              startDate: DateTime.now(),
              source: RecordSource.manual,
            ),
          );
      await db
          .into(db.places)
          .insert(
            PlacesCompanion.insert(
              name: 'Home',
              latitude: 1,
              longitude: 2,
              source: RecordSource.manual,
            ),
          );
      await db
          .into(db.trips)
          .insert(
            TripsCompanion.insert(
              startedAt: DateTime.now(),
              source: RecordSource.location,
            ),
          );
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              activityType: ActivityType.running,
              startedAt: DateTime.now(),
              source: RecordSource.manual,
            ),
          );
      await db
          .into(db.notes)
          .insert(
            NotesCompanion.insert(
              content: 'Private note',
              noteDate: DateTime.now(),
              source: RecordSource.manual,
            ),
          );

      await db.wipeAllLocalData();

      expect(await db.select(db.locationPoints).get(), isEmpty);
      expect(await db.select(db.healthSamples).get(), isEmpty);
      expect(await db.select(db.activitySamples).get(), isEmpty);
      expect(await db.select(db.goals).get(), isEmpty);
      expect(await db.select(db.places).get(), isEmpty);
      expect(await db.select(db.trips).get(), isEmpty);
      expect(await db.select(db.workoutSessions).get(), isEmpty);
      expect(await db.select(db.notes).get(), isEmpty);
      // Device identity is sync-critical, not "tracked personal data" — a
      // local wipe must not silently break the app's own sync identity.
      expect(await db.select(db.devices).get(), hasLength(1));
    },
  );

  test('a pending-upload location point survives closing and reopening the '
      'database file (process-death recovery — no queued data lost)', () async {
    final dir = await Directory.systemTemp.createTemp('ambulo_durability_test');
    addTearDown(() => dir.delete(recursive: true));
    final dbFile = File(p.join(dir.path, 'durability_test.sqlite'));

    var db = AppDatabase.forTesting(NativeDatabase(dbFile));
    await db
        .into(db.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: 51.5,
            longitude: -0.12,
            recordedAt: DateTime.utc(2026, 1, 1),
            monitoringMode: MonitoringMode.significant,
            source: RecordSource.location,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
    // Simulate the process dying right after the write reached disk —
    // no orderly shutdown, no flush step to rely on.
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    final rows = await db.select(db.locationPoints).get();
    expect(rows, hasLength(1));
    expect(rows.single.syncState, SyncState.pendingUpload);
    expect(rows.single.latitude, 51.5);
  });
}
