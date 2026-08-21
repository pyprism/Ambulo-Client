import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/health_samples_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/data/repositories/health_connect_repository.dart';
import 'package:ambulo/platform/fitness/health_connect_adapter.dart';

/// Test double for the native boundary — never touches the `health`
/// package/platform channels, so these tests exercise the repository's
/// pure-Dart aggregation/dedup/cutoff logic against a real in-memory DB.
class _FakeHealthConnectAdapter extends HealthConnectAdapter {
  _FakeHealthConnectAdapter({this.granted = true, this.points = const []});

  final bool granted;
  final List<HealthConnectPoint> points;

  @override
  Future<bool> requestPermissions() async => granted;

  @override
  Future<List<HealthConnectPoint>> readAll({
    required DateTime start,
    required DateTime end,
  }) async => points;
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedMotionSteps(DateTime day, double steps) async {
    await db
        .into(db.healthSamples)
        .insert(
          HealthSamplesCompanion.insert(
            metricType: HealthMetricType.steps,
            value: steps,
            recordedAt: day,
            source: RecordSource.motion,
            syncState: const Value(SyncState.synced),
          ),
        );
  }

  test('returns null when permission is denied', () async {
    final repo = HealthConnectRepository(
      db,
      _FakeHealthConnectAdapter(granted: false),
    );
    final summary = await repo.connectAndImportAll();
    expect(summary, isNull);
  });

  test('aggregates same-day points into one daily sum per metric', () async {
    final day = DateTime(2026, 3, 1);
    final repo = HealthConnectRepository(
      db,
      _FakeHealthConnectAdapter(
        points: [
          HealthConnectPoint(
            metricType: HealthMetricType.steps,
            value: 3000,
            recordedAt: day.add(const Duration(hours: 8)),
          ),
          HealthConnectPoint(
            metricType: HealthMetricType.steps,
            value: 2000,
            recordedAt: day.add(const Duration(hours: 14)),
          ),
          HealthConnectPoint(
            metricType: HealthMetricType.distance,
            value: 1500,
            recordedAt: day.add(const Duration(hours: 9)),
          ),
        ],
      ),
    );

    final summary = await repo.connectAndImportAll();
    expect(summary, isNotNull);
    expect(summary!.imported[HealthMetricType.steps], 1);
    expect(summary.imported[HealthMetricType.distance], 1);

    final steps = await (db.select(
      db.healthSamples,
    )..where((t) => t.metricType.equalsValue(HealthMetricType.steps))).get();
    expect(steps, hasLength(1));
    expect(steps.single.value, 5000);
    expect(steps.single.source, RecordSource.health);
  });

  test('steps backfill stops before the earliest existing local steps day; '
      'distance/calories are unaffected', () async {
    final cutoffDay = DateTime(2026, 3, 10);
    await seedMotionSteps(cutoffDay, 1000);

    final before = cutoffDay.subtract(const Duration(days: 1));
    final repo = HealthConnectRepository(
      db,
      _FakeHealthConnectAdapter(
        points: [
          HealthConnectPoint(
            metricType: HealthMetricType.steps,
            value: 500,
            recordedAt: before,
          ),
          HealthConnectPoint(
            metricType: HealthMetricType.steps,
            value: 999,
            recordedAt: cutoffDay,
          ),
          HealthConnectPoint(
            metricType: HealthMetricType.distance,
            value: 200,
            recordedAt: cutoffDay,
          ),
        ],
      ),
    );

    final summary = await repo.connectAndImportAll();
    expect(summary!.imported[HealthMetricType.steps], 1); // only `before`
    expect(summary.imported[HealthMetricType.distance], 1); // unaffected

    final stepsRows = await (db.select(
      db.healthSamples,
    )..where((t) => t.metricType.equalsValue(HealthMetricType.steps))).get();
    // The pre-seeded motion row for cutoffDay, plus the backfilled `before`
    // row — never a second steps row for cutoffDay itself.
    expect(stepsRows, hasLength(2));
    final cutoffRow = stepsRows.firstWhere((r) => r.recordedAt == cutoffDay);
    expect(cutoffRow.value, 1000); // untouched, not doubled to 1999
  });

  test('with no existing local steps row, backfill cutoff is today '
      '(yesterday imports, today is left to the live pedometer)', () async {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final yesterday = today.subtract(const Duration(days: 1));
    final repo = HealthConnectRepository(
      db,
      _FakeHealthConnectAdapter(
        points: [
          HealthConnectPoint(
            metricType: HealthMetricType.steps,
            value: 100,
            recordedAt: yesterday,
          ),
          HealthConnectPoint(
            metricType: HealthMetricType.steps,
            value: 200,
            recordedAt: today,
          ),
        ],
      ),
    );

    final summary = await repo.connectAndImportAll();
    expect(summary!.imported[HealthMetricType.steps], 1);
    final stepsRows = await db.select(db.healthSamples).get();
    expect(stepsRows, hasLength(1));
    expect(stepsRows.single.recordedAt, yesterday);
  });

  test('reconnecting with identical data is idempotent and does not '
      're-flag already-synced rows as pending', () async {
    final day = DateTime(2026, 3, 1);
    final points = [
      HealthConnectPoint(
        metricType: HealthMetricType.distance,
        value: 1000,
        recordedAt: day,
      ),
    ];
    final repo = HealthConnectRepository(
      db,
      _FakeHealthConnectAdapter(points: points),
    );

    final first = await repo.connectAndImportAll();
    expect(first!.imported[HealthMetricType.distance], 1);

    final rowAfterFirst =
        await (db.select(db.healthSamples)..where(
              (t) => t.metricType.equalsValue(HealthMetricType.distance),
            ))
            .getSingle();
    await db
        .update(db.healthSamples)
        .replace(rowAfterFirst.copyWith(syncState: SyncState.synced));

    final second = await repo.connectAndImportAll();
    expect(second!.imported[HealthMetricType.distance], isNull);
    expect(second.unchanged, 1);

    final rowAfterSecond =
        await (db.select(db.healthSamples)..where(
              (t) => t.metricType.equalsValue(HealthMetricType.distance),
            ))
            .getSingle();
    // Untouched — still synced, not bumped back to pendingUpload.
    expect(rowAfterSecond.syncState, SyncState.synced);
    expect(rowAfterSecond.localRev, rowAfterFirst.localRev);
  });

  test(
    'recomputes id deterministically so reconnect updates in place',
    () async {
      final day = DateTime(2026, 4, 5);
      final repoA = HealthConnectRepository(
        db,
        _FakeHealthConnectAdapter(
          points: [
            HealthConnectPoint(
              metricType: HealthMetricType.calories,
              value: 100,
              recordedAt: day,
            ),
          ],
        ),
      );
      await repoA.connectAndImportAll();

      final repoB = HealthConnectRepository(
        db,
        _FakeHealthConnectAdapter(
          points: [
            HealthConnectPoint(
              metricType: HealthMetricType.calories,
              value: 150,
              recordedAt: day,
            ),
          ],
        ),
      );
      final second = await repoB.connectAndImportAll();
      expect(second!.imported[HealthMetricType.calories], 1);

      final rows =
          await (db.select(db.healthSamples)..where(
                (t) => t.metricType.equalsValue(HealthMetricType.calories),
              ))
              .get();
      // Updated in place, not duplicated.
      expect(rows, hasLength(1));
      expect(rows.single.value, 150);
    },
  );
}
