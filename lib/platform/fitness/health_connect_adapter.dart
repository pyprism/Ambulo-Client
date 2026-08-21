import 'package:flutter/foundation.dart';
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
    this.sourceName = '',
  });

  final HealthMetricType metricType;
  final double value;
  final DateTime recordedAt;

  /// Package name of the app/device stream this reading came from, used by
  /// `HealthConnectRepository` to collapse the same day's competing sources
  /// instead of summing them. Defaults to a single unnamed source.
  final String sourceName;
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

// `health` 13.3.2's `getHealthAggregateDataFromTypes` is unusable on
// Android: the Dart side sends `dataTypeKeys`/`activitySegmentDuration`
// while `HealthDataReader.getAggregateData` reads `dataTypeKey`/`interval`,
// so both come back null and the Kotlin `!!` throws before the call even
// reaches Health Connect. 13.3.2 is the latest release, so there's no
// version to upgrade to. Everything below works around that by using only
// the two channel methods whose argument names actually line up:
// `getTotalStepsInInterval` and `getData`.

/// Raw records are fetched in windows this wide rather than one day at a
/// time — the day-at-a-time loop this replaced issued one platform call per
/// calendar day back to 2010 (~5,700 round trips per import, nearly all of
/// them over empty ranges).
const _rawScanChunk = Duration(days: 90);

/// Source name stamped on step totals, which Health Connect has already
/// merged across every underlying stream — one synthetic source, so the
/// repository's max-per-source reduction passes the value through untouched.
const _aggregateSource = 'healthconnect:aggregate';

// Health Connect returns every underlying record from every source stream
// (phone, watch, Samsung Health, …) un-deduplicated, so summing them
// double-counts any day covered by more than one source. Steps avoid this
// entirely via the aggregate API. Distance and calories have no working
// aggregate path in 13.3.2, so each day takes the *largest* single-source
// total instead of the sum across sources: the phone and the watch both
// track the same walk, and the more complete of the two is much closer to
// the truth than their sum. The known cost is an undercount on days where
// two sources genuinely covered disjoint periods.

/// Thin wrapper around the `health` package — the only part of this feature
/// that can't be exercised without a real Android device + Health Connect
/// app + Google Fit history, so it stays intentionally free of dedup and
/// aggregation logic (that lives in `HealthConnectRepository`, which is
/// plain Dart and unit-testable). It translates the `health` package's types
/// into Ambulo's and decides which windows to ask the platform for; it never
/// decides what a day's total is. The one apparent exception, per-day step
/// totals, is Health Connect doing the aggregating, not this class.
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
    // Each native hop is labelled: a `PlatformException` raised inside any of
    // them surfaces only as an opaque JVM message (Health Connect and its
    // transitive `device_info_plus` dependency both throw them), which on its
    // own doesn't say *which* call failed. The step name is the only thing
    // that separates a `configure()` (device_info_plus) failure from a Health
    // Connect one when all we have to go on is a user-reported snackbar.
    await _step('configure', () => _health.configure());
    if (!await _step('availability check', _health.isHealthConnectAvailable)) {
      throw HealthConnectUnavailableException(
        'Health Connect isn\'t installed on this device.',
        needsInstall: true,
      );
    }
    final granted = await _step(
      'permission request',
      () => _health.requestAuthorization(_requestedTypes),
    );
    if (!granted) return false;
    // Best-effort, and that has to include *crashing*: full history is the
    // point of this feature, but the data-type grant above is what actually
    // makes it usable. If the user declines this extra grant — or the plugin
    // throws on the way to asking — later reads fall back to Health Connect's
    // default 30-day window instead of the whole import failing. Swallowed
    // rather than routed through `_step`, which rethrows.
    try {
      await _health.requestHealthDataHistoryAuthorization();
    } catch (e) {
      debugPrint('Health Connect history grant skipped: $e');
    }
    return true;
  }

  /// Runs [action], re-throwing anything it raises as a
  /// [HealthConnectUnavailableException] tagged with [step].
  Future<T> _step<T>(String step, Future<T> Function() action) async {
    try {
      return await action();
    } on HealthConnectUnavailableException {
      rethrow;
    } catch (e) {
      throw HealthConnectUnavailableException(
        'Health Connect $step failed: $e',
      );
    }
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

  /// Every reading in [start, end), as raw per-source rows for distance and
  /// calories plus one already-deduplicated total per day for steps.
  ///
  /// Pure I/O: bucketing readings into days and collapsing competing sources
  /// happens in `HealthConnectRepository`, where it is unit-testable.
  ///
  /// Two passes, because 13.3.2 leaves us two working tools:
  ///
  ///  1. A chunked raw scan ([_rawScanChunk]) over the whole range. It
  ///     supplies distance/calories readings directly, and — for steps —
  ///     only the *set of days that actually hold data*, so pass 2 never
  ///     queries an empty day.
  ///  2. One `getTotalStepsInInterval` call per step day. That routes to
  ///     Health Connect's own `aggregate(StepsRecord.COUNT_TOTAL)`, so steps
  ///     come back exactly deduplicated rather than needing the
  ///     max-per-source approximation distance and calories settle for.
  ///
  /// [stepsAggregateBefore] skips pass 2 for days at or after it — the
  /// caller already knows it will discard those in favour of the pedometer,
  /// and each one costs a platform round trip.
  Future<List<HealthConnectPoint>> readAll({
    required DateTime start,
    required DateTime end,
    DateTime? stepsAggregateBefore,
  }) async {
    final raw = await _rawScan(start: _startOfDay(start), end: end);

    final points = <HealthConnectPoint>[];
    final stepDays = <DateTime>{};
    for (final record in raw) {
      final metricType = _metricTypeFor(record.type);
      final value = record.value;
      if (metricType == null || value is! NumericHealthValue) continue;
      if (metricType == HealthMetricType.steps) {
        // Value deliberately dropped — pass 2 re-reads the day exactly.
        stepDays.add(_startOfDay(record.dateFrom));
        continue;
      }
      points.add(
        HealthConnectPoint(
          metricType: metricType,
          value: value.numericValue.toDouble(),
          recordedAt: record.dateFrom,
          sourceName: record.sourceName,
        ),
      );
    }

    for (final day in stepDays) {
      if (stepsAggregateBefore != null && !day.isBefore(stepsAggregateBefore)) {
        continue;
      }
      final dayEnd = day.add(const Duration(days: 1));
      final steps = await _health.getTotalStepsInInterval(
        day,
        dayEnd.isAfter(end) ? end : dayEnd,
      );
      if (steps == null) continue;
      points.add(
        HealthConnectPoint(
          metricType: HealthMetricType.steps,
          value: steps.toDouble(),
          recordedAt: day,
          sourceName: _aggregateSource,
        ),
      );
    }

    return points;
  }

  /// Raw per-source records across the whole range, fetched in
  /// [_rawScanChunk]-wide windows to bound how much comes back per call.
  Future<List<HealthDataPoint>> _rawScan({
    required DateTime start,
    required DateTime end,
  }) async {
    final raw = <HealthDataPoint>[];
    var chunkStart = start;
    while (chunkStart.isBefore(end)) {
      final chunkEnd = chunkStart.add(_rawScanChunk);
      raw.addAll(
        await _health.getHealthDataFromTypes(
          types: _requestedTypes,
          startTime: chunkStart,
          endTime: chunkEnd.isAfter(end) ? end : chunkEnd,
        ),
      );
      chunkStart = chunkEnd;
    }
    return raw;
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Exact deduplicated step total in `[start, end)` — used to anchor the
  /// pedometer's day-rollover baseline, where [readAll]'s day-bucketed
  /// aggregation would be both too coarse (an arbitrary intraday `start`)
  /// and unnecessary (only steps are needed here, not every metric type).
  Future<int?> totalStepsBetween(DateTime start, DateTime end) {
    return _health.getTotalStepsInInterval(start, end);
  }
}
