import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// Mirrors server `utils.enums.HealthMetricType`.
enum HealthMetricType {
  steps,
  distance,
  activeMinutes,
  calories,
  floors,
  weight,
  height,
  water,
  sleep,
  mood,
  heartRate,
  custom,
}

/// Phone-sensor or manually-entered health metric (steps, distance, floors,
/// active minutes, calories are the phone-sensor v1 set; the rest are
/// manual-entry fields already supported by the shared server model).
// Continuously-growing (pedometer/GPS write throughout the day) — daily
// stats (`FitnessStatsRepository`) filter by metric + day range constantly,
// mirroring the server's own (user, metric_type, recorded_at) index.
@TableIndex(
  name: 'idx_health_samples_metric_recorded',
  columns: {#metricType, #recordedAt},
)
@TableIndex(name: 'idx_health_samples_sync_state', columns: {#syncState})
class HealthSamples extends Table with SyncableColumns {
  TextColumn get metricType => textEnum<HealthMetricType>()();
  RealColumn get value => real()();
  TextColumn get unit => text().withDefault(const Constant(''))();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
}
