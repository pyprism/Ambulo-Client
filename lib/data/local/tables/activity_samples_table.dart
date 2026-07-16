import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// Mirrors server `utils.enums.ActivityType`.
enum ActivityType { still, walking, running, cycling, vehicle, unknown }

/// A detected activity segment, derived from location speed while a
/// monitoring mode with active tracking is on (still/walking/running/
/// cycling/vehicle). Contributes to active-minutes and distance-by-activity.
// One new row per activity-type change while tracking — grows continuously
// alongside LocationPoints, so the sync-state count query needs the same
// protection.
@TableIndex(name: 'idx_activity_samples_sync_state', columns: {#syncState})
class ActivitySamples extends Table with SyncableColumns {
  TextColumn get activityType => textEnum<ActivityType>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get confidence => real().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  IntColumn get steps => integer().nullable()();
}
