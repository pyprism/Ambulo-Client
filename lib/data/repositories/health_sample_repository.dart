import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/tables/health_samples_table.dart';
import '../local/tables/sync_columns.dart';

/// Manual entry of a health metric (e.g. a weight or height reading typed
/// in on the Personal data settings screen) — sensor-written metrics
/// (steps, distance, ...) go through their own tracking services instead.
class HealthSampleRepository {
  HealthSampleRepository(this._db);

  final AppDatabase _db;

  Future<void> addManualSample({
    required HealthMetricType metricType,
    required double value,
    String unit = '',
    DateTime? recordedAt,
  }) async {
    await _db
        .into(_db.healthSamples)
        .insert(
          HealthSamplesCompanion.insert(
            metricType: metricType,
            value: value,
            unit: Value(unit),
            recordedAt: recordedAt ?? DateTime.now(),
            source: RecordSource.manual,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
  }
}
