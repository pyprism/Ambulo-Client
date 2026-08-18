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
const _lastCounterKey = 'pedometer_last_counter';
const _lastSeenAtKey = 'pedometer_last_counter_seen_at_ms';

/// How long before midnight the last observed counter reading may be for
/// [rolloverBaseline] to still credit the unattributed steps to the new day.
///
/// This is the fallback path only — on Android with Health Connect granted,
/// the baseline is derived exactly and this window never applies. Here the
/// carry-over may include steps actually walked the previous evening, so
/// it's a trade: over-report by an evening's steps, or (as before) drop an
/// entire morning walk to zero. Over-reporting wins, but the window still
/// has to end somewhere, and people don't reliably open a tracking app late
/// at night — a few hours would miss the very case this fixes.
const _maxCarryOverGap = Duration(hours: 12);

/// Health Connect is off the app's critical path here; if it stalls, fall
/// back to the heuristic rather than wedging the pedometer's work chain.
const _healthConnectBaselineTimeout = Duration(seconds: 10);

/// Picks the baseline for a day rollover: the counter value that should map
/// to "0 steps today".
///
/// The naive answer is the current reading, but the app process is normally
/// dead across midnight, so the first callback of a new day often arrives
/// *after* the user has already walked — `counter` then includes that walk
/// and anchoring to it silently discards steps the hardware did count. That
/// is why a walk taken before the day's first app launch showed up as zero.
///
/// Anchoring to the last counter value this device actually observed lets
/// the unattributed delta land on today instead. Steps taken between that
/// observation and midnight get credited to today too, so this only applies
/// when the observation was recent enough for that error to be bounded (see
/// [_maxCarryOverGap]); otherwise it falls back to `null` (anchor to the
/// current reading, i.e. the old behavior).
///
/// Returns `null` when no usable carry-over exists — including after a
/// reboot (`lastCounter > counter`), where the pre-reboot counter is
/// meaningless.
@visibleForTesting
int? rolloverBaseline({
  required int counter,
  required int? lastCounter,
  required DateTime? lastSeenAt,
  required DateTime today,
}) {
  if (lastCounter == null || lastSeenAt == null) return null;
  if (lastCounter > counter) return null;
  final startOfToday = DateTime(today.year, today.month, today.day);
  if (startOfToday.difference(lastSeenAt) > _maxCarryOverGap) return null;
  return lastCounter;
}

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
    Future<int?> Function(DateTime start, DateTime end)? healthConnectSteps,
  }) : _deviceId = deviceId, // ignore: prefer_initializing_formals
       _onUpdate = onUpdate, // ignore: prefer_initializing_formals
       // ignore: prefer_initializing_formals
       _healthConnectSteps = healthConnectSteps;

  final AppDatabase _db;
  final Future<String> Function() _deviceId;
  final VoidCallback? _onUpdate;

  /// Exact steps-in-range lookup used only to anchor a day-rollover
  /// baseline; null where Health Connect isn't a thing (iOS, web, tests).
  final Future<int?> Function(DateTime start, DateTime end)?
  _healthConnectSteps;
  StreamSubscription<StepCount>? _subscription;
  Future<void> _work = Future<void>.value();
  StepTrackingStatus _status = StepTrackingStatus.inactive;

  static const _flushEveryStepsCount = 20;
  int? _pendingStepsToday;
  int? _pendingRawCounter;
  DateTime? _pendingRawCounterAt;
  DateTime? _pendingDay;
  int? _lastPersistedStepsToday;
  String? _lastPersistedDayKey;

  StepTrackingStatus get status => _status;

  Future<T> _serialize<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _work = _work.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  // Routed through _serialize like stop()/flush() — start() has an async
  // gap (the activity-recognition permission request) between the
  // `_subscription != null` check and the assignment, so two concurrent
  // callers (e.g. a pause-toggle listener and the ready-gated first apply)
  // could otherwise both pass the null check and subscribe twice, leaking
  // the first subscription and double-processing every step event. Sharing
  // _work with stop() also means a stop() queued mid-start can't race in
  // and leave `_status = inactive` with a live subscription.
  Future<StepTrackingStatus> start() => _serialize(_start);

  Future<StepTrackingStatus> _start() async {
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
      (event) => _serialize(() => _onStepCount(event)),
      onError: (_) => _status = StepTrackingStatus.permissionDenied,
      cancelOnError: false,
    );
    return _status = StepTrackingStatus.active;
  }

  Future<void> stop() async {
    await _serialize(() async {
      await _flushPending();
      await _subscription?.cancel();
      _subscription = null;
      _status = StepTrackingStatus.inactive;
    });
  }

  /// Persists any buffered-but-unwritten step count — call this at points
  /// where losing the buffer would be user-visible (app backgrounding) even
  /// though the flush threshold hasn't been hit yet.
  Future<void> flush() => _serialize(_flushPending);

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = _dayKey(today);
    final storedDateKey = prefs.getString(_baselineDateKey);
    var baseline = prefs.getInt(_baselineKey);

    final isNewDay = storedDateKey != todayKey;
    final isBootReset = baseline != null && event.steps < baseline;
    if (isNewDay || isBootReset || baseline == null) {
      if (isBootReset && !isNewDay) {
        // A boot reset mid-day must carry forward whatever was already
        // recorded today rather than zeroing it out — the sensor's
        // cumulative counter restarted, not the user's day. Folding the
        // carry-over into the persisted baseline (rather than adding it only
        // on this one callback) keeps every later `event.steps - baseline`
        // correct too, not just this callback's.
        baseline = event.steps - await _todayStoredSteps(today);
      } else {
        // The pending buffer (if any) still describes a *previous* day at
        // this point — flush it before it's overwritten below with today's
        // values, or its unflushed tail (< _flushEveryStepsCount steps)
        // never reaches the DB at all.
        if (_pendingDay != null && _dayKey(_pendingDay!) != todayKey) {
          await _flushPending();
        }
        baseline = await resolveRolloverBaseline(event.steps, today);
      }
      await prefs.setInt(_baselineKey, baseline);
      await prefs.setString(_baselineDateKey, todayKey);
    }

    final stepsToday = (event.steps - baseline).clamp(0, 1 << 30);
    _pendingStepsToday = stepsToday;
    _pendingRawCounter = event.steps;
    // The moment this counter value was *observed*, not the moment it later
    // gets flushed — a flush on backgrounding can land long after the last
    // callback, and pairing an old counter with a fresh timestamp would
    // quietly stretch [_maxCarryOverGap] past the elapsed time it bounds.
    _pendingRawCounterAt = today;
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
    final counter = _pendingRawCounter;
    final counterAt = _pendingRawCounterAt;
    if (steps == null || day == null) return;
    // Recorded even when the step total hasn't moved since the last flush:
    // the day-rollover baseline needs to know *when* this counter value was
    // last observed, and `flush()` runs on backgrounding precisely so that
    // observation is as close as possible to "phone goes in the pocket".
    if (counter != null && counterAt != null) {
      await _rememberCounter(counter, counterAt);
    }
    final dayKey = _dayKey(day);
    if (_lastPersistedStepsToday == steps && _lastPersistedDayKey == dayKey) {
      return;
    }
    await _upsertTodaySteps(steps, day);
    _lastPersistedStepsToday = steps;
    _lastPersistedDayKey = dayKey;
    _onUpdate?.call();
  }

  /// Baseline for a fresh day (or a first-ever run): the counter value that
  /// maps to "0 steps today". Prefers Health Connect's timestamped answer
  /// and falls back to the [rolloverBaseline] heuristic, then to the raw
  /// counter (the old, walk-dropping behavior) when neither can answer.
  @visibleForTesting
  Future<int> resolveRolloverBaseline(int counter, DateTime today) async {
    final startOfToday = DateTime(today.year, today.month, today.day);
    final healthConnectSteps = _healthConnectSteps;
    if (healthConnectSteps != null) {
      int? steps;
      try {
        steps = await healthConnectSteps(
          startOfToday,
          today,
        ).timeout(_healthConnectBaselineTimeout);
      } catch (_) {
        // Timeout, missing grant, native failure — all just mean "Health
        // Connect can't answer", which the heuristic below handles.
        steps = null;
      }
      if (steps != null && steps >= 0 && steps <= counter) {
        return counter - steps;
      }
      // steps > counter is implausible on its face: the since-boot counter
      // necessarily includes every step taken today, so Health Connect
      // cannot legitimately report more for "today alone". A genuine
      // midnight reboot is already caught separately by the
      // `event.steps < baseline` check in `_onStepCount` — treating this
      // case as "must be a reboot" and anchoring at zero instead credited
      // Health Connect's bad answer wholesale (the entire since-boot
      // counter logged as today's steps, the inflated-count bug this guards
      // against). Fall through to the heuristic/raw-counter path instead of
      // trusting either extreme.
    }
    final prefs = await SharedPreferences.getInstance();
    return rolloverBaseline(
          counter: counter,
          lastCounter: prefs.getInt(_lastCounterKey),
          lastSeenAt: _lastSeenAt(prefs),
          today: today,
        ) ??
        counter;
  }

  Future<void> _rememberCounter(int counter, DateTime observedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCounterKey, counter);
    await prefs.setInt(_lastSeenAtKey, observedAt.millisecondsSinceEpoch);
  }

  DateTime? _lastSeenAt(SharedPreferences prefs) {
    final ms = prefs.getInt(_lastSeenAtKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
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
    //
    // Tombstones are excluded to match `FitnessStatsRepository`, which only
    // sums live rows — updating a deleted row instead of inserting a fresh
    // one would leave the day stuck at zero with no way to recover.
    final rows =
        await (_db.select(_db.healthSamples)..where(
              (t) =>
                  t.metricType.equalsValue(HealthMetricType.steps) &
                  t.recordedAt.isBiggerOrEqualValue(startOfDay) &
                  t.recordedAt.isSmallerThanValue(endOfDay) &
                  t.deviceId.equals(deviceId) &
                  t.deletedAt.isNull(),
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
