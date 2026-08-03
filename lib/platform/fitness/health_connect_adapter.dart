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

// Health Connect's own read window cap per query (unrelated to the >30-day
// history *authorization* gate below) — chunk long backfills into windows
// this size rather than one unbounded range query.
const _readWindow = Duration(days: 30);

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

  /// Reads every requested data type across [start, end), chunked into
  /// [_readWindow]-sized queries (Health Connect's own per-query cap).
  Future<List<HealthConnectPoint>> readAll({
    required DateTime start,
    required DateTime end,
  }) async {
    final points = <HealthConnectPoint>[];
    var windowStart = start;
    while (windowStart.isBefore(end)) {
      final windowEnd = windowStart.add(_readWindow).isAfter(end)
          ? end
          : windowStart.add(_readWindow);
      final raw = await _health.getHealthDataFromTypes(
        types: _requestedTypes,
        startTime: windowStart,
        endTime: windowEnd,
      );
      for (final point in raw) {
        final metricType = _metricTypeFor(point.type);
        final value = point.value;
        if (metricType == null || value is! NumericHealthValue) continue;
        points.add(
          HealthConnectPoint(
            metricType: metricType,
            value: value.numericValue.toDouble(),
            recordedAt: point.dateFrom,
          ),
        );
      }
      windowStart = windowEnd;
    }
    return points;
  }
}
