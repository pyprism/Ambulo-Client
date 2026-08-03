import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../platform/fitness/health_connect_adapter.dart';
import '../local/database.dart';
import '../local/sync_mutation.dart';
import '../local/tables/health_samples_table.dart';
import '../local/tables/sync_columns.dart';

/// Per-metric-type counts from a Health Connect import pass.
class HealthConnectImportSummary {
  const HealthConnectImportSummary({
    required this.imported,
    required this.unchanged,
  });

  /// Days written or updated, keyed by metric type.
  final Map<HealthMetricType, int> imported;

  /// Days seen but already up to date locally — not re-flagged pending.
  final int unchanged;

  int get totalImported =>
      imported.values.fold(0, (total, count) => total + count);
}

/// Health Connect predates any real user data by a wide margin — a cheap,
/// generous lower bound for "read everything" rather than a real cutoff.
final _earliestPossibleDate = DateTime(2010);

/// Maps Health Connect data into local `HealthSamples` rows and hands the
/// mapping/dedup/aggregation logic (the part that doesn't need a device) to
/// pure Dart, unit-testable independently of the native adapter.
class HealthConnectRepository {
  HealthConnectRepository(this._db, [HealthConnectAdapter? adapter])
    : _adapter = adapter ?? HealthConnectAdapter();

  final AppDatabase _db;
  final HealthConnectAdapter _adapter;

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns null if permission was requested but the user declined it —
  /// callers should show that as "not granted", not an error. Throws
  /// [HealthConnectUnavailableException] if Health Connect itself can't be
  /// used at all (wrong platform, not installed).
  Future<void> promptInstallHealthConnect() => _adapter.promptInstall();

  /// Exact number of steps Health Connect has recorded in `[start, end)`, or
  /// null when it can't answer — wrong platform, app not installed,
  /// permission never granted, or no step samples in the window.
  ///
  /// Used to anchor the pedometer's day-rollover baseline. The phone's
  /// hardware step counter is cumulative-since-boot and carries no
  /// timestamps, so once the app has been killed across midnight it cannot
  /// tell which side of midnight its unattributed steps fall on. Health
  /// Connect's samples do carry timestamps, so it can — see
  /// `StepTrackingService`.
  ///
  /// This never writes a `HealthSamples` row, so the "Health Connect only
  /// backfills days before the earliest local pedometer row" rule still
  /// holds: `FitnessStatsRepository` keeps summing exactly one source per
  /// day. Nothing here prompts, so it's safe from a sensor callback.
  Future<int?> stepsBetween(DateTime start, DateTime end) async {
    try {
      if (!await _adapter.hasStepsPermission()) return null;
      final points = await _adapter.readAll(start: start, end: end);
      final steps = points
          .where((point) => point.metricType == HealthMetricType.steps)
          .toList();
      if (steps.isEmpty) return null;
      return steps
          .fold<double>(0, (total, point) => total + point.value)
          .round();
    } catch (_) {
      // A rollover baseline is a best-effort refinement — never let a
      // Health Connect failure take down step tracking itself.
      return null;
    }
  }

  Future<HealthConnectImportSummary?> connectAndImportAll() async {
    final granted = await _adapter.requestPermissions();
    if (!granted) return null;

    // Steps already has a live writer (the pedometer, `source: motion`),
    // and `FitnessStatsRepository.statsForDay` sums every row for a day
    // across sources — so Health Connect must not backfill a day the
    // pedometer already covers, or that day's step count doubles. Distance
    // and calories have no existing local writer, so they backfill freely.
    final stepsCutoff = await _stepsCutoffDate();

    final points = await _adapter.readAll(
      start: _earliestPossibleDate,
      end: DateTime.now(),
    );
    final daily = _aggregateByDay(points);

    final imported = <HealthMetricType, int>{};
    var unchanged = 0;
    for (final entry in daily.entries) {
      final (metricType, day) = entry.key;
      if (metricType == HealthMetricType.steps && !day.isBefore(stepsCutoff)) {
        continue;
      }
      final wrote = await _upsertDay(metricType, day, entry.value);
      if (wrote) {
        imported.update(metricType, (n) => n + 1, ifAbsent: () => 1);
      } else {
        unchanged++;
      }
    }
    return HealthConnectImportSummary(imported: imported, unchanged: unchanged);
  }

  Future<DateTime> _stepsCutoffDate() async {
    final today = _startOfDay(DateTime.now());
    final earliest =
        await (_db.select(_db.healthSamples)
              ..where(
                (t) =>
                    t.metricType.equalsValue(HealthMetricType.steps) &
                    t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (earliest == null) return today;
    final earliestDay = _startOfDay(earliest.recordedAt);
    return earliestDay.isBefore(today) ? earliestDay : today;
  }

  Map<(HealthMetricType, DateTime), double> _aggregateByDay(
    List<HealthConnectPoint> points,
  ) {
    final daily = <(HealthMetricType, DateTime), double>{};
    for (final point in points) {
      final key = (point.metricType, _startOfDay(point.recordedAt));
      daily.update(
        key,
        (value) => value + point.value,
        ifAbsent: () => point.value,
      );
    }
    return daily;
  }

  String _idFor(HealthMetricType metricType, DateTime day) {
    final iso = day.toIso8601String().split('T').first;
    return const Uuid().v5(
      Namespace.url.value,
      'healthconnect:${metricType.name}:$iso',
    );
  }

  /// Returns true if a row was written (new or changed), false if an
  /// identical row already existed and nothing was touched.
  Future<bool> _upsertDay(
    HealthMetricType metricType,
    DateTime day,
    double value,
  ) async {
    final id = _idFor(metricType, day);
    final existing = await (_db.select(
      _db.healthSamples,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    if (existing != null) {
      if (existing.value == value) return false;
      final bump = SyncBump(existing.localRev);
      await (_db.update(
        _db.healthSamples,
      )..where((t) => t.id.equals(id))).write(
        HealthSamplesCompanion(
          value: Value(value),
          updatedAt: bump.updatedAt,
          localRev: bump.localRev,
          syncState: bump.syncState,
        ),
      );
      return true;
    }

    await _db
        .into(_db.healthSamples)
        .insert(
          HealthSamplesCompanion.insert(
            id: Value(id),
            metricType: metricType,
            value: value,
            recordedAt: day,
            source: RecordSource.health,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
    return true;
  }
}
