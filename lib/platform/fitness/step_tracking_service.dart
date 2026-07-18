import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/database.dart';
import '../../data/local/sync_mutation.dart';
import '../../data/local/tables/health_samples_table.dart';
import '../../data/local/tables/sync_columns.dart';
import '../platform_support.dart';

const _baselineKey = 'pedometer_baseline_steps';
const _baselineDateKey = 'pedometer_baseline_date';

/// Outcome of the most recent [StepTrackingService.start] attempt — lets
/// Settings/Diagnostics explain why steps aren't counting instead of it
/// silently not happening (mirrors `LocationTrackingStatus`).
enum StepTrackingStatus { inactive, active, permissionDenied }

/// `Pedometer.stepCountStream` reports steps since the device's last boot,
/// not since midnight — this tracks a per-day baseline locally and upserts
/// a single `HealthSamples(metric_type: steps)` row per day (per device)
/// with today's count, rather than writing one row per sensor callback.
///
/// Runs continuously (gated only by the incognito pause toggle, not by
/// monitoring mode) — the step-counter sensor is a hardware-batched,
/// low-power counter, not a radio, so it doesn't carry GPS's battery cost.
/// DB writes are debounced (every [_flushEveryStepsCount] steps, or at a
/// day/pause boundary) rather than one write per pedometer callback.
class StepTrackingService {
  // Params stay public-named (`deviceId`, `onUpdate`) rather than
  // initializing formals, which would force callers to use the private
  // field names (`_deviceId:`, `_onUpdate:`) as named-argument labels.
  StepTrackingService(
    this._db, {
    required Future<String> Function() deviceId,
    VoidCallback? onUpdate,
  }) : _deviceId = deviceId, // ignore: prefer_initializing_formals
       _onUpdate = onUpdate; // ignore: prefer_initializing_formals

  final AppDatabase _db;
  final Future<String> Function() _deviceId;
  final VoidCallback? _onUpdate;
  StreamSubscription<StepCount>? _subscription;
  StepTrackingStatus _status = StepTrackingStatus.inactive;

  static const _flushEveryStepsCount = 20;
  int? _pendingStepsToday;
  DateTime? _pendingDay;
  int? _lastPersistedStepsToday;
  String? _lastPersistedDayKey;

  StepTrackingStatus get status => _status;

  Future<StepTrackingStatus> start() async {
    if (!PlatformSupport.supportsSensorCollection) {
      return _status = StepTrackingStatus.inactive;
    }
    if (_subscription != null) return _status;

    // Reading the step-counter sensor on Android 10+ needs this
    // runtime-dangerous permission; the pedometer plugin doesn't request it
    // itself, so without this the sensor listener silently never fires.
    if (defaultTargetPlatform == TargetPlatform.android) {
      var permission = await Permission.activityRecognition.status;
      if (!permission.isGranted) {
        permission = await Permission.activityRecognition.request();
      }
      if (!permission.isGranted) {
        return _status = StepTrackingStatus.permissionDenied;
      }
    }

    _subscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (_) => _status = StepTrackingStatus.permissionDenied,
      cancelOnError: false,
    );
    return _status = StepTrackingStatus.active;
  }

  Future<void> stop() async {
    await _flushPending();
    await _subscription?.cancel();
    _subscription = null;
    _status = StepTrackingStatus.inactive;
  }

  /// Persists any buffered-but-unwritten step count — call this at points
  /// where losing the buffer would be user-visible (app backgrounding) even
  /// though the flush threshold hasn't been hit yet.
  Future<void> flush() => _flushPending();

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = _dayKey(today);
    final storedDateKey = prefs.getString(_baselineDateKey);
    var baseline = prefs.getInt(_baselineKey);

    final isNewDay = storedDateKey != todayKey;
    final isBootReset = baseline != null && event.steps < baseline;
    if (isNewDay || isBootReset || baseline == null) {
      // A boot reset mid-day must carry forward whatever was already
      // recorded today rather than zeroing it out — the sensor's
      // cumulative counter restarted, not the user's day. Folding the
      // carry-over into the persisted baseline (rather than adding it only
      // on this one callback) keeps every later `event.steps - baseline`
      // correct too, not just this callback's.
      final carryOverSteps = (isBootReset && !isNewDay)
          ? await _todayStoredSteps(today)
          : 0;
      baseline = event.steps - carryOverSteps;
      await prefs.setInt(_baselineKey, baseline);
      await prefs.setString(_baselineDateKey, todayKey);
    }

    final stepsToday = (event.steps - baseline).clamp(0, 1 << 30);
    _pendingStepsToday = stepsToday;
    _pendingDay = today;

    final delta = _lastPersistedStepsToday == null
        ? _flushEveryStepsCount
        : stepsToday - _lastPersistedStepsToday!;
    final dayChanged = _lastPersistedDayKey != todayKey;
    if (dayChanged || delta >= _flushEveryStepsCount) {
      await _flushPending();
    }
  }

  Future<void> _flushPending() async {
    final steps = _pendingStepsToday;
    final day = _pendingDay;
    if (steps == null || day == null) return;
    final dayKey = _dayKey(day);
    if (_lastPersistedStepsToday == steps && _lastPersistedDayKey == dayKey) {
      return;
    }
    await _upsertTodaySteps(steps, day);
    _lastPersistedStepsToday = steps;
    _lastPersistedDayKey = dayKey;
    _onUpdate?.call();
  }

  String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<int> _todayStoredSteps(DateTime day) async {
    final row = await _todayRow(day);
    return row?.value.round() ?? 0;
  }

  Future<HealthSample?> _todayRow(DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final deviceId = await _deviceId();

    // Filtered to this device's own row: sync is multi-device by default,
    // so another device (or an import) may have already written its own
    // steps row for today. `.get()` + take-first tolerates any stray
    // duplicate instead of throwing, unlike `getSingleOrNull()`.
    final rows =
        await (_db.select(_db.healthSamples)..where(
              (t) =>
                  t.metricType.equalsValue(HealthMetricType.steps) &
                  t.recordedAt.isBiggerOrEqualValue(startOfDay) &
                  t.recordedAt.isSmallerThanValue(endOfDay) &
                  t.deviceId.equals(deviceId),
            ))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> _upsertTodaySteps(int steps, DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final deviceId = await _deviceId();
    final existing = await _todayRow(day);

    if (existing != null) {
      final bump = SyncBump(existing.localRev);
      await (_db.update(
        _db.healthSamples,
      )..where((t) => t.id.equals(existing.id))).write(
        HealthSamplesCompanion(
          value: Value(steps.toDouble()),
          updatedAt: bump.updatedAt,
          localRev: bump.localRev,
          syncState: bump.syncState,
        ),
      );
    } else {
      await _db
          .into(_db.healthSamples)
          .insert(
            HealthSamplesCompanion.insert(
              metricType: HealthMetricType.steps,
              value: steps.toDouble(),
              unit: const Value('steps'),
              recordedAt: startOfDay,
              deviceId: Value(deviceId),
              source: RecordSource.motion,
              syncState: const Value(SyncState.pendingUpload),
            ),
          );
    }
  }
}
