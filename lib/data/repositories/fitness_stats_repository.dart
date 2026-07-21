import 'package:drift/drift.dart';

import '../../features/fitness/user_profile_controller.dart';
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

// The flat-rate fallback constants below (0.04 kcal/step, 5.0 kcal/active
// minute) were tuned for roughly this reference body weight; when the user
// has entered their own weight, scale by weightKg/_referenceWeightKg instead
// of using a single fixed rate for everyone.
const _referenceWeightKg = 80.0;

/// Local, on-device fitness rollups — computed on demand from
/// HealthSamples/ActivitySamples/LocationPoints rather than a separate
/// materialized rollup table, so it always reflects this device's data
/// whether or not the server has been reached. Calorie/floor figures are
/// explicit estimates, not clinical measurements.
class FitnessStatsRepository {
  FitnessStatsRepository(this._db, [this._profile]);

  final AppDatabase _db;
  final UserProfile? _profile;

  /// Mifflin-St Jeor BMR (kcal/day). Null unless weight, height, age, and
  /// sex are all available — a partial profile isn't enough to estimate
  /// this. Weight/height come from the most recent HealthSample reading of
  /// that type, not the profile — they're time-series data, not static
  /// attributes (see `UserProfile` doc comment).
  double? _bmrPerDay(double? weightKg, double? heightCm) {
    final profile = _profile;
    final age = profile?.age;
    final sex = profile?.sex;
    if (weightKg == null || heightCm == null || age == null || sex == null) {
      return null;
    }
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    final sexOffset = switch (sex) {
      BiologicalSex.male => 5.0,
      BiologicalSex.female => -161.0,
      // No sex-specific constant applies; split the difference between the
      // male/female offsets rather than guessing one or the other.
      BiologicalSex.other => -78.0,
    };
    return base + sexOffset;
  }

  /// Most recent reading of a manually-tracked metric (weight, height) —
  /// unlike steps, these aren't summed across the day, just the latest
  /// known value regardless of when it was recorded.
  Future<double?> latestSampleValue(HealthMetricType metric) async {
    final row =
        await (_db.select(_db.healthSamples)
              ..where(
                (t) => t.metricType.equalsValue(metric) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.value;
  }

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
            _db.healthSamples.recordedAt.isSmallerThanValue(end) &
            _db.healthSamples.deletedAt.isNull(),
      );
    final stepsRow = await stepsQuery.getSingle();
    final steps = (stepsRow.read(stepsSum) ?? 0).round();

    final segments =
        await (_db.select(_db.activitySamples)..where(
              (t) =>
                  t.startedAt.isSmallerThanValue(end) &
                  (t.endedAt.isBiggerOrEqualValue(start) | t.endedAt.isNull()) &
                  t.deletedAt.isNull(),
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
                    t.recordedAt.isSmallerThanValue(end) &
                    t.deletedAt.isNull(),
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

    // With a full personal profile: BMR (resting burn) + activity on top,
    // scaled by the user's actual weight instead of the flat reference rate.
    // Without one: the original rough flat-rate estimate — not a clinical
    // calculation either way.
    final weightKg = await latestSampleValue(HealthMetricType.weight);
    final heightCm = await latestSampleValue(HealthMetricType.height);
    final bmr = _bmrPerDay(weightKg, heightCm);
    final double calories;
    if (bmr != null) {
      final weightScale = weightKg! / _referenceWeightKg;
      final effectiveEnd = now.isBefore(end) ? now : end;
      final elapsedSeconds = effectiveEnd.isAfter(start)
          ? effectiveEnd.difference(start).inSeconds
          : 0;
      final dayFraction = (elapsedSeconds / const Duration(days: 1).inSeconds)
          .clamp(0.0, 1.0);
      final activeCalories =
          steps * 0.04 * weightScale + activeMinutes * 5.0 * weightScale;
      calories = bmr * dayFraction + activeCalories;
    } else {
      calories = steps * 0.04 + activeMinutes * 5.0;
    }

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

  /// Raw weight readings in range, oldest first — unlike `statsForRange`
  /// this isn't a per-day rollup, since weight is a point-in-time reading,
  /// not something to sum across a day.
  Future<List<(DateTime, double)>> weightHistory(
    DateTime start,
    DateTime end,
  ) async {
    final rangeStart = _startOfDay(start);
    final rangeEnd = _startOfDay(end).add(const Duration(days: 1));
    final rows =
        await (_db.select(_db.healthSamples)
              ..where(
                (t) =>
                    t.metricType.equalsValue(HealthMetricType.weight) &
                    t.recordedAt.isBiggerOrEqualValue(rangeStart) &
                    t.recordedAt.isSmallerThanValue(rangeEnd) &
                    t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
            .get();
    return [for (final row in rows) (row.recordedAt, row.value)];
  }
}
