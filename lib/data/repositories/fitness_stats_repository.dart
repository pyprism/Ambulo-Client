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

// GPS vertical error is routinely 10-30m, so ungated altitude deltas
// generate phantom floors on flat ground; only trust readings at least this
// accurate, and only credit a floor once a climb has been sustained across
// more than one consecutive reading (a lone noisy point shouldn't count).
const _maxVerticalAccuracyMeters = 10.0;
const _floorHeightMeters = 3.0;
const _minSustainedClimbPoints = 2;

/// Local, on-device fitness rollups — computed on demand from
/// HealthSamples/ActivitySamples/LocationPoints rather than a separate
/// materialized rollup table, so it always reflects this device's data
/// whether or not the server has been reached. Calorie/floor figures are
/// explicit estimates, not clinical measurements.
class FitnessStatsRepository {
  FitnessStatsRepository(this._db);

  final AppDatabase _db;

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<DailyStats> statsForDay(DateTime day) async {
    final start = _startOfDay(day);
    final end = start.add(const Duration(days: 1));
    final now = DateTime.now();

    // Multi-device by default: a second device (or an import) can write its
    // own steps row for the same day, so this sums across every row for the
    // day rather than assuming exactly one exists (which throws on 2+ rows
    // with getSingleOrNull()). Cross-device double-counting policy (e.g.
    // phone + watch on the same walk) is a separate, deferred decision.
    final stepsSum = _db.healthSamples.value.sum();
    final stepsQuery = _db.selectOnly(_db.healthSamples)
      ..addColumns([stepsSum])
      ..where(
        _db.healthSamples.metricType.equalsValue(HealthMetricType.steps) &
            _db.healthSamples.recordedAt.isBiggerOrEqualValue(start) &
            _db.healthSamples.recordedAt.isSmallerThanValue(end),
      );
    final stepsRow = await stepsQuery.getSingle();
    final steps = (stepsRow.read(stepsSum) ?? 0).round();

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
      final fullEnd = segment.endedAt ?? now;
      final segmentStart = segment.startedAt.isBefore(start)
          ? start
          : segment.startedAt;
      final segmentEnd = fullEnd.isAfter(end) ? end : fullEnd;
      if (segmentEnd.isBefore(segmentStart)) continue;

      // A segment spanning midnight is clipped to this day's window, but
      // its distance covers its *full* span — prorate by the clipped
      // fraction of the segment's duration instead of double-counting the
      // full distance on both days.
      final fullMicros = fullEnd.difference(segment.startedAt).inMicroseconds;
      final clippedMicros = segmentEnd.difference(segmentStart).inMicroseconds;
      final fraction = fullMicros > 0 ? clippedMicros / fullMicros : 1.0;
      distanceMeters += (segment.distanceMeters ?? 0) * fraction;

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
    var consecutiveClimbPoints = 0;
    for (final point in locationPoints) {
      final altitude = point.altitude;
      final verticalAccuracy = point.verticalAccuracy;
      // geolocator reports 0.0 for an accuracy that isn't available on this
      // device, not a genuinely perfect fix — don't let that bypass the gate.
      final hasReliableAltitude =
          altitude != null &&
          verticalAccuracy != null &&
          verticalAccuracy > 0 &&
          verticalAccuracy <= _maxVerticalAccuracyMeters;
      if (!hasReliableAltitude) {
        previousAltitude = null;
        climbSinceLastFloor = 0;
        consecutiveClimbPoints = 0;
        continue;
      }
      if (previousAltitude != null) {
        final delta = altitude - previousAltitude;
        if (delta > 0) {
          climbSinceLastFloor += delta;
          consecutiveClimbPoints++;
          if (consecutiveClimbPoints >= _minSustainedClimbPoints) {
            while (climbSinceLastFloor >= _floorHeightMeters) {
              floors++;
              climbSinceLastFloor -= _floorHeightMeters;
            }
          }
        } else {
          climbSinceLastFloor = 0;
          consecutiveClimbPoints = 0;
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
