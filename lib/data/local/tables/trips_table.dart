import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// Client-recorded route: the client groups points into a trip while
/// tracking, the server just stores the container.
class Trips extends Table with SyncableColumns {
  TextColumn get name => text().withDefault(const Constant(''))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get distanceMeters => real().withDefault(const Constant(0))();
  IntColumn get pointCount => integer().withDefault(const Constant(0))();
  TextColumn get startPlaceId => text().nullable()();
  TextColumn get endPlaceId => text().nullable()();
}
