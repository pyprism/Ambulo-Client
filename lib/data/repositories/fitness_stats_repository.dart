import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/tables/activity_samples_table.dart';
import '../local/tables/health_samples_table.dart';

class DailyStats {
  const DailyStats({
    required this.date,
    required this.steps,
    required this.distanceMeters,
    required this.activeMinutes,
    required this.calories,
    required this.floors,
  });

  final DateTime date;
  final int steps;
  final double distanceMeters;
  final int activeMinutes;
  final double calories;
  final int floors;
}

const _movingActivityTypes = {
  ActivityType.walking,
  ActivityType.running,
  ActivityType.cycling,
};

/// Local, on-device fitness rollups — computed on demand from
/// HealthSamples/ActivitySamples/LocationPoints rather than a separate
/// materialized rollup table, so it always reflects this device's data
/// whether or not the server has been reached. Calorie/floor figures are
/// explicit estimates (SPEC calls out "calorie estimate" and "activity
/// estimate"), not clinical measurements.
class FitnessStatsRepository {
  FitnessStatsRepository(this._db);

  final AppDatabase _db;

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<DailyStats> statsForDay(DateTime day) async {
    final start = _startOfDay(day);
    final end = start.add(const Duration(days: 1));
    final now = DateTime.now();

    final stepsRow =
        await (_db.select(_db.healthSamples)..where(
              (t) =>
                  t.metricType.equalsValue(HealthMetricType.steps) &
                  t.recordedAt.isBiggerOrEqualValue(start) &
                  t.recordedAt.isSmallerThanValue(end),
            ))
            .getSingleOrNull();
    final steps = stepsRow?.value.round() ?? 0;

    final segments =
        await (_db.select(_db.activitySamples)..where(
              (t) =>
                  t.startedAt.isSmallerThanValue(end) &
                  (t.endedAt.isBiggerOrEqualValue(start) | t.endedAt.isNull()),
            ))
            .get();

    var distanceMeters = 0.0;
    var activeSeconds = 0;
    for (final segment in segments) {
      final segmentStart = segment.startedAt.isBefore(start)
          ? start
          : segment.startedAt;
      final segmentEnd = (segment.endedAt ?? now).isAfter(end)
          ? end
          : (segment.endedAt ?? now);
      if (segmentEnd.isBefore(segmentStart)) continue;

      distanceMeters += segment.distanceMeters ?? 0;
      if (_movingActivityTypes.contains(segment.activityType)) {
        activeSeconds += segmentEnd.difference(segmentStart).inSeconds;
      }
    }
    final activeMinutes = (activeSeconds / 60).round();

    final locationPoints =
        await (_db.select(_db.locationPoints)
              ..where(
                (t) =>
                    t.recordedAt.isBiggerOrEqualValue(start) &
                    t.recordedAt.isSmallerThanValue(end),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
            .get();
    var floors = 0;
    double? previousAltitude;
    var climbSinceLastFloor = 0.0;
    for (final point in locationPoints) {
      final altitude = point.altitude;
      if (altitude == null) continue;
      if (previousAltitude != null) {
        final delta = altitude - previousAltitude;
        if (delta > 0) {
          climbSinceLastFloor += delta;
          while (climbSinceLastFloor >= 3.0) {
            floors++;
            climbSinceLastFloor -= 3.0;
          }
        }
      }
      previousAltitude = altitude;
    }

    // Rough estimate: ~0.04 kcal/step plus a flat rate for sustained moving
    // activity — not a clinical calculation.
    final calories = steps * 0.04 + activeMinutes * 5.0;

    return DailyStats(
      date: start,
      steps: steps,
      distanceMeters: distanceMeters,
      activeMinutes: activeMinutes,
      calories: calories,
      floors: floors,
    );
  }

  Future<List<DailyStats>> statsForRange(DateTime start, DateTime end) async {
    final days = <DailyStats>[];
    var cursor = _startOfDay(start);
    final last = _startOfDay(end);
    while (!cursor.isAfter(last)) {
      days.add(await statsForDay(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }
}
