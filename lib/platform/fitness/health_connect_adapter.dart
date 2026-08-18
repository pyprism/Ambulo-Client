import 'package:health/health.dart';

import '../../data/local/tables/health_samples_table.dart';
import '../platform_support.dart';

/// One raw reading handed up from Health Connect, already translated to
/// Ambulo's own [HealthMetricType] — everything above this adapter is
/// pure Dart and knows nothing about the `health` package's types.
class HealthConnectPoint {
  HealthConnectPoint({
    required this.metricType,
    required this.value,
    required this.recordedAt,
  });

  final HealthMetricType metricType;
  final double value;
  final DateTime recordedAt;
}

/// Thrown when Health Connect itself (not a specific read) can't proceed.
class HealthConnectUnavailableException implements Exception {
  HealthConnectUnavailableException(this.message, {this.needsInstall = false});
  final String message;

  /// True when the fix is "prompt the user to install the Health Connect
  /// app", as opposed to some other unavailability reason.
  final bool needsInstall;

  @override
  String toString() => message;
}

const _requestedTypes = [
  HealthDataType.STEPS,
  HealthDataType.DISTANCE_DELTA,
  HealthDataType.ACTIVE_ENERGY_BURNED,
];

HealthMetricType? _metricTypeFor(HealthDataType type) => switch (type) {
  HealthDataType.STEPS => HealthMetricType.steps,
  HealthDataType.DISTANCE_DELTA => HealthMetricType.distance,
  HealthDataType.ACTIVE_ENERGY_BURNED => HealthMetricType.calories,
  _ => null,
};

// One calendar day per aggregate query. Health Connect's raw
// getHealthDataFromTypes returns *every* underlying record from every
// source app/device stream (Google Fit phone, watch, Samsung Health, …)
// unaggregated — summing those double- and triple-counts any day covered by
// more than one stream. Querying the aggregate API one day at a time keeps
// each call's own cross-source dedup scoped to exactly one calendar day, so
// a record spanning a day boundary can't get attributed (or double
// attributed) across two of our buckets the way summing raw dateFrom-keyed
// records could.
const _aggregateWindow = Duration(days: 1);

/// Thin wrapper around the `health` package — the only part of this feature
/// that can't be exercised without a real Android device + Health Connect
/// app + Google Fit history, so it stays intentionally free of any mapping,
/// dedup, or aggregation logic (that lives in `HealthConnectRepository`,
/// which is plain Dart and unit-testable).
class HealthConnectAdapter {
  HealthConnectAdapter([Health? health]) : _health = health ?? Health();

  final Health _health;

  /// Requests every permission this feature needs (data types + the
  /// separate >30-day history grant) and throws
  /// [HealthConnectUnavailableException] if the flow can't proceed at all.
  /// Returns false (not an exception) if the user simply denies a
  /// permission prompt — that's a normal outcome the caller should show as
  /// "permission not granted", not an error.
  Future<bool> requestPermissions() async {
    if (!PlatformSupport.supportsHealthConnect) {
      throw HealthConnectUnavailableException(
        'Health Connect is only available on Android.',
      );
    }
    await _health.configure();
    if (!await _health.isHealthConnectAvailable()) {
      throw HealthConnectUnavailableException(
        'Health Connect isn\'t installed on this device.',
        needsInstall: true,
      );
    }
    final granted = await _health.requestAuthorization(_requestedTypes);
    if (!granted) return false;
    // Best-effort: full history is the point of this feature, but if the
    // user declines just this extra grant, later reads silently fall back
    // to Health Connect's default 30-day window rather than failing.
    await _health.requestHealthDataHistoryAuthorization();
    return true;
  }

  Future<void> promptInstall() => _health.installHealthConnect();

  /// Non-prompting check for an existing steps grant. [requestPermissions]
  /// can pop a system dialog, which callers driven by a sensor callback
  /// (the pedometer's day-rollover baseline) must never do — they use this
  /// to decide whether a read is worth attempting at all.
  Future<bool> hasStepsPermission() async {
    if (!PlatformSupport.supportsHealthConnect) return false;
    await _health.configure();
    if (!await _health.isHealthConnectAvailable()) return false;
    return await _health.hasPermissions([HealthDataType.STEPS]) ?? false;
  }

  /// Reads every requested data type across [start, end) as one aggregated,
  /// deduplicated total per metric per calendar day — never raw per-source
  /// records (see [_aggregateWindow]).
  Future<List<HealthConnectPoint>> readAll({
    required DateTime start,
    required DateTime end,
  }) async {
    final points = <HealthConnectPoint>[];
    var dayStart = DateTime(start.year, start.month, start.day);
    while (dayStart.isBefore(end)) {
      final dayEnd = dayStart.add(_aggregateWindow);
      final windowEnd = dayEnd.isAfter(end) ? end : dayEnd;
      final raw = await _health.getHealthAggregateDataFromTypes(
        types: _requestedTypes,
        startDate: dayStart,
        endDate: windowEnd,
      );
      for (final point in raw) {
        final metricType = _metricTypeFor(point.type);
        final value = point.value;
        if (metricType == null || value is! NumericHealthValue) continue;
        points.add(
          HealthConnectPoint(
            metricType: metricType,
            value: value.numericValue.toDouble(),
            // Stamped with the query window's own day rather than trusting
            // the aggregate point's dateFrom — the whole point of querying
            // one day at a time is that every point returned belongs to
            // this day, regardless of which moment inside it dateFrom
            // happens to report.
            recordedAt: dayStart,
          ),
        );
      }
      dayStart = dayEnd;
    }
    return points;
  }

  /// Exact deduplicated step total in `[start, end)` — used to anchor the
  /// pedometer's day-rollover baseline, where [readAll]'s day-bucketed
  /// aggregation would be both too coarse (an arbitrary intraday `start`)
  /// and unnecessary (only steps are needed here, not every metric type).
  Future<int?> totalStepsBetween(DateTime start, DateTime end) {
    return _health.getTotalStepsInInterval(start, end);
  }
}
