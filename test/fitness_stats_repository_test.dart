import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/activity_samples_table.dart';
import 'package:ambulo/data/local/tables/health_samples_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/data/repositories/fitness_stats_repository.dart';

void main() {
  late AppDatabase db;
  late FitnessStatsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FitnessStatsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedHealthSample(
    HealthMetricType metricType,
    double value,
    DateTime recordedAt, {
    RecordSource source = RecordSource.health,
  }) async {
    await db
        .into(db.healthSamples)
        .insert(
          HealthSamplesCompanion.insert(
            metricType: metricType,
            value: value,
            recordedAt: recordedAt,
            source: source,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
  }

  Future<void> seedActivitySegment(
    DateTime start,
    DateTime end,
    double distanceMeters,
  ) async {
    await db
        .into(db.activitySamples)
        .insert(
          ActivitySamplesCompanion.insert(
            activityType: ActivityType.walking,
            startedAt: start,
            endedAt: Value(end),
            distanceMeters: Value(distanceMeters),
            source: RecordSource.motion,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
  }

  test('distance falls back to the Health-Connect total on a day with no '
      'GPS/workout distance at all', () async {
    final oldDay = DateTime(2020, 1, 15);
    await seedHealthSample(HealthMetricType.distance, 4200, oldDay);

    final stats = await repo.statsForDay(oldDay);
    expect(stats.distanceMeters, 4200);
  });

  test('distance prefers the GPS-derived value over a co-existing '
      'Health-Connect row for the same day', () async {
    final day = DateTime(2026, 3, 1);
    await seedActivitySegment(
      day.add(const Duration(hours: 8)),
      day.add(const Duration(hours: 9)),
      1000,
    );
    await seedHealthSample(HealthMetricType.distance, 9999, day);

    final stats = await repo.statsForDay(day);
    expect(stats.distanceMeters, 1000);
  });

  test('calories falls back to the Health-Connect total on a day with no '
      'local activity signal (no steps, active minutes, or workout)', () async {
    final oldDay = DateTime(2020, 1, 15);
    await seedHealthSample(HealthMetricType.calories, 1800, oldDay);

    final stats = await repo.statsForDay(oldDay);
    expect(stats.calories, 1800);
  });

  test(
    'calories stays driven by the live estimate — not frozen on a '
    "same-day Health-Connect snapshot — once today has any local signal",
    () async {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      // Mimics the live pedometer having already recorded some of today.
      await seedHealthSample(
        HealthMetricType.steps,
        1000,
        today,
        source: RecordSource.motion,
      );
      // A stale snapshot from whenever the user last hit "Connect".
      await seedHealthSample(HealthMetricType.calories, 42, today);

      final stats = await repo.statsForDay(today);
      // Flat-rate formula (no profile set): steps * 0.04, not the frozen 42.
      expect(stats.calories, closeTo(1000 * 0.04, 0.01));
    },
  );
}
