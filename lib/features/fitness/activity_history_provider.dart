import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';

/// Reactive, most-recent-first activity segment history.
final activityHistoryProvider = StreamProvider<List<ActivitySample>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.activitySamples)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(100))
      .watch();
});
