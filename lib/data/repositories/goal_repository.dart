import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/sync_mutation.dart';
import '../local/tables/goals_table.dart';
import '../local/tables/health_samples_table.dart';
import '../local/tables/sync_columns.dart';

class GoalRepository {
  GoalRepository(this._db);

  final AppDatabase _db;

  Future<void> setDailyGoal(HealthMetricType metric, double target) async {
    final existing =
        await (_db.select(_db.goals)
              ..where(
                (t) =>
                    t.metricType.equalsValue(metric) &
                    t.period.equalsValue(GoalPeriod.daily) &
                    t.isActive.equals(true) &
                    t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.goals)
          .insert(
            GoalsCompanion.insert(
              metricType: metric,
              targetValue: target,
              startDate: DateTime.now(),
              source: RecordSource.manual,
              syncState: const Value(SyncState.pendingUpload),
            ),
          );
      return;
    }
    final bump = SyncBump(existing.localRev);
    await (_db.update(_db.goals)..where((t) => t.id.equals(existing.id))).write(
      GoalsCompanion(
        targetValue: Value(target),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }
}
