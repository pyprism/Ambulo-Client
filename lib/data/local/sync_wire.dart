import 'tables/health_samples_table.dart';
import 'tables/sync_columns.dart';

/// Dart enum <-> server wire-string mapping. `RecordSource`, `MonitoringMode`,
/// `Connectivity`, `ActivityType` and `GoalPeriod` values already match their
/// server wire values 1:1 (single lowercase words), so only `SyncState` and
/// `HealthMetricType` (camelCase locally) need an explicit table.
String syncStateToWire(SyncState state) => switch (state) {
  SyncState.localOnly => 'local_only',
  SyncState.pendingUpload => 'pending_upload',
  SyncState.synced => 'synced',
  SyncState.conflict => 'conflict',
  SyncState.failed => 'failed',
  SyncState.deletedPendingSync => 'deleted_pending_sync',
};

SyncState syncStateFromWire(String value) => switch (value) {
  'local_only' => SyncState.localOnly,
  'pending_upload' => SyncState.pendingUpload,
  'synced' => SyncState.synced,
  'conflict' => SyncState.conflict,
  'deleted_pending_sync' => SyncState.deletedPendingSync,
  _ => SyncState.failed,
};

String healthMetricTypeToWire(HealthMetricType type) => switch (type) {
  HealthMetricType.steps => 'steps',
  HealthMetricType.distance => 'distance',
  HealthMetricType.activeMinutes => 'active_minutes',
  HealthMetricType.calories => 'calories',
  HealthMetricType.floors => 'floors',
  HealthMetricType.weight => 'weight',
  HealthMetricType.height => 'height',
  HealthMetricType.water => 'water',
  HealthMetricType.sleep => 'sleep',
  HealthMetricType.mood => 'mood',
  HealthMetricType.heartRate => 'heart_rate',
  HealthMetricType.custom => 'custom',
};

HealthMetricType healthMetricTypeFromWire(String value) => switch (value) {
  'steps' => HealthMetricType.steps,
  'distance' => HealthMetricType.distance,
  'active_minutes' => HealthMetricType.activeMinutes,
  'calories' => HealthMetricType.calories,
  'floors' => HealthMetricType.floors,
  'weight' => HealthMetricType.weight,
  'height' => HealthMetricType.height,
  'water' => HealthMetricType.water,
  'sleep' => HealthMetricType.sleep,
  'mood' => HealthMetricType.mood,
  'heart_rate' => HealthMetricType.heartRate,
  _ => HealthMetricType.custom,
};
