import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/sync_mutation.dart';
import '../local/tables/activity_samples_table.dart';
import '../local/tables/sync_columns.dart';

class WorkoutSessionRepository {
  WorkoutSessionRepository(this._db);

  final AppDatabase _db;

  Future<void> addWorkout({
    required ActivityType activityType,
    required DateTime startedAt,
    DateTime? endedAt,
    double? distanceMeters,
    double? calories,
    String notes = '',
  }) async {
    await _db
        .into(_db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            activityType: activityType,
            startedAt: startedAt,
            endedAt: Value(endedAt),
            distanceMeters: Value(distanceMeters),
            calories: Value(calories),
            notes: Value(notes),
            source: RecordSource.manual,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
  }

  Future<void> updateWorkout(
    String id, {
    ActivityType? activityType,
    DateTime? startedAt,
    DateTime? endedAt,
    double? distanceMeters,
    double? calories,
    String? notes,
  }) async {
    final current = await (_db.select(
      _db.workoutSessions,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.workoutSessions,
    )..where((t) => t.id.equals(id))).write(
      WorkoutSessionsCompanion(
        activityType: activityType == null
            ? const Value.absent()
            : Value(activityType),
        startedAt: startedAt == null ? const Value.absent() : Value(startedAt),
        endedAt: endedAt == null ? const Value.absent() : Value(endedAt),
        distanceMeters: distanceMeters == null
            ? const Value.absent()
            : Value(distanceMeters),
        calories: calories == null ? const Value.absent() : Value(calories),
        notes: notes == null ? const Value.absent() : Value(notes),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }

  Future<void> deleteWorkout(String id) async {
    final current = await (_db.select(
      _db.workoutSessions,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.workoutSessions,
    )..where((t) => t.id.equals(id))).write(
      WorkoutSessionsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }
}
