import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/sync_mutation.dart';
import '../local/tables/activity_samples_table.dart';

class ActivitySampleRepository {
  ActivitySampleRepository(this._db);

  final AppDatabase _db;

  /// Reclassify only — start/end/distance/steps are sensor-derived, not
  /// something to hand-edit.
  Future<void> updateActivityType(String id, ActivityType activityType) async {
    final current = await (_db.select(
      _db.activitySamples,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.activitySamples,
    )..where((t) => t.id.equals(id))).write(
      ActivitySamplesCompanion(
        activityType: Value(activityType),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }

  Future<void> deleteActivitySample(String id) async {
    final current = await (_db.select(
      _db.activitySamples,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.activitySamples,
    )..where((t) => t.id.equals(id))).write(
      ActivitySamplesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }
}
