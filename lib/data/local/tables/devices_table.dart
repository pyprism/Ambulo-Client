import 'package:drift/drift.dart';

/// Local device registry (multi-device by default). This app's own
/// device identity plus any devices known via sync download.
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get platform => text()(); // android / ios / web
  TextColumn get appVersion => text().nullable()();
  BoolColumn get isCurrentDevice =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get registeredAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeenAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
