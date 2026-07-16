import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Base sync fields required on every syncable record: client UUID pk,
/// device id, created/updated/deleted (tombstone) timestamps, local_rev,
/// server_rev, sync_state, source.
mixin SyncableColumns on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get userId => text().nullable()();
  TextColumn get deviceId => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  IntColumn get localRev => integer().withDefault(const Constant(1))();
  IntColumn get serverRev => integer().nullable()();

  TextColumn get syncState =>
      textEnum<SyncState>().withDefault(const Constant('localOnly'))();
  TextColumn get source => textEnum<RecordSource>()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirrors server `utils.enums.SyncState` (wire values are snake_case;
/// mapped explicitly in the sync repository, not relied on via enum.name).
enum SyncState {
  localOnly,
  pendingUpload,
  synced,
  conflict,
  failed,
  deletedPendingSync,
}

/// Mirrors server `utils.enums.SyncSource`.
enum RecordSource { manual, location, motion, health, import, server }
