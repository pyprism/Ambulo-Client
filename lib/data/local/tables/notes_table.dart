import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// A free-form dated note — mirrors server `health.models.Note`.
class Notes extends Table with SyncableColumns {
  TextColumn get content => text()();
  DateTimeColumn get noteDate => dateTime()();
  TextColumn get context => text().withDefault(const Constant(''))();
}
