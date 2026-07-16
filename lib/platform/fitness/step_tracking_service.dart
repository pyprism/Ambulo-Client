import 'dart:async';

import 'package:drift/drift.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/database.dart';
import '../../data/local/sync_mutation.dart';
import '../../data/local/tables/health_samples_table.dart';
import '../../data/local/tables/sync_columns.dart';
import '../platform_support.dart';

const _baselineKey = 'pedometer_baseline_steps';
const _baselineDateKey = 'pedometer_baseline_date';

/// `Pedometer.stepCountStream` reports steps since the device's last boot,
/// not since midnight — this tracks a per-day baseline locally and upserts
/// a single `HealthSamples(metric_type: steps)` row per day with
/// today's count, rather than writing one row per sensor callback.
class StepTrackingService {
  StepTrackingService(this._db);

  final AppDatabase _db;
  StreamSubscription<StepCount>? _subscription;

  void start() {
    if (!PlatformSupport.supportsSensorCollection) return;
    if (_subscription != null) return;
    _subscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = _dayKey(today);
    final storedDateKey = prefs.getString(_baselineDateKey);
    var baseline = prefs.getInt(_baselineKey);

    final isNewDay = storedDateKey != todayKey;
    final isBootReset = baseline != null && event.steps < baseline;
    if (isNewDay || isBootReset || baseline == null) {
      baseline = event.steps;
      await prefs.setInt(_baselineKey, baseline);
      await prefs.setString(_baselineDateKey, todayKey);
    }

    final stepsToday = (event.steps - baseline).clamp(0, 1 << 30);
    await _upsertTodaySteps(stepsToday, today);
  }

  String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _upsertTodaySteps(int steps, DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing =
        await (_db.select(_db.healthSamples)..where(
              (t) =>
                  t.metricType.equalsValue(HealthMetricType.steps) &
                  t.recordedAt.isBiggerOrEqualValue(startOfDay) &
                  t.recordedAt.isSmallerThanValue(endOfDay),
            ))
            .getSingleOrNull();

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
              source: RecordSource.motion,
              syncState: const Value(SyncState.pendingUpload),
            ),
          );
    }
  }
}
