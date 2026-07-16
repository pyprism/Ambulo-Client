import 'package:drift/drift.dart';

import 'activity_samples_table.dart';
import 'sync_columns.dart';

/// A user-logged workout (distinct from the auto-detected `ActivitySamples`
/// segments) — mirrors server `health.models.WorkoutSession`.
class WorkoutSessions extends Table with SyncableColumns {
  TextColumn get activityType => textEnum<ActivityType>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  RealColumn get calories => real().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}
