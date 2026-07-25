import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/activity_samples_table.dart';
import 'package:ambulo/data/local/tables/health_samples_table.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/data/repositories/fitness_stats_repository.dart';
import 'package:ambulo/features/fitness/user_profile_controller.dart';

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

  test('clips a midnight-spanning activity to the requested day', () async {
    final day = DateTime(2020, 1, 15);
    await seedActivitySegment(
      day.subtract(const Duration(minutes: 30)),
      day.add(const Duration(minutes: 30)),
      600,
    );

    final stats = await repo.statsForDay(day);

    expect(stats.distanceMeters, closeTo(300, 0.01));
    expect(stats.activeMinutes, 30);
  });

  test('counts floors only from sustained, reliable climbs', () async {
    final day = DateTime(2020, 1, 15);
    Future<void> point(int minute, double altitude, double accuracy) => db
        .into(db.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: 51.5,
            longitude: -0.12,
            altitude: Value(altitude),
            verticalAccuracy: Value(accuracy),
            recordedAt: day.add(Duration(minutes: minute)),
            monitoringMode: MonitoringMode.manual,
            source: RecordSource.motion,
          ),
        );

    await point(0, 10, 5);
    await point(1, 12, 5);
    await point(2, 14, 5);
    await point(3, 30, 0); // Missing accuracy resets the climb sequence.
    await point(4, 20, 5);
    await point(5, 22, 5);
    await point(6, 24, 5);

    expect((await repo.statsForDay(day)).floors, 2);
  });

  test('uses profile BMR plus weight-scaled activity for past days', () async {
    final day = DateTime(2020, 1, 15);
    repo = FitnessStatsRepository(
      db,
      UserProfile(dateOfBirth: DateTime(1990, 1, 1), sex: BiologicalSex.male),
    );
    await seedHealthSample(HealthMetricType.weight, 80, day);
    await seedHealthSample(HealthMetricType.height, 180, day);
    await seedHealthSample(HealthMetricType.steps, 1000, day);

    final stats = await repo.statsForDay(day);
    final age = UserProfile(dateOfBirth: DateTime(1990, 1, 1)).age!;
    final expectedBmr = 10 * 80 + 6.25 * 180 - 5 * age + 5;
    // Historic days have a full-day BMR fraction, and 1,000 steps add 40 kcal.
    expect(stats.calories, closeTo(expectedBmr + 40, 0.01));
  });

  test(
    'returns inclusive day rollups and chronologically sorted weight history',
    () async {
      final first = DateTime(2020, 1, 15);
      final second = first.add(const Duration(days: 1));
      await seedHealthSample(HealthMetricType.steps, 100, first);
      await seedHealthSample(HealthMetricType.steps, 200, second);
      await seedHealthSample(HealthMetricType.weight, 72, second);
      await seedHealthSample(HealthMetricType.weight, 71, first);

      final stats = await repo.statsForRange(first, second);
      final weights = await repo.weightHistory(first, second);

      expect(stats.map((day) => day.steps), [100, 200]);
      expect(weights, [(first, 71.0), (second, 72.0)]);
    },
  );
}
