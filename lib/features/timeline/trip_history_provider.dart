import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';

/// Reactive, most-recent-first trip history for the timeline.
final tripHistoryProvider = StreamProvider<List<Trip>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.trips)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(200))
      .watch();
});
