import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';

/// Reactive, most-recent-first location history for the map (and, later,
/// the timeline). Capped so a multi-year dataset doesn't get pulled into
/// memory just to draw a route.
final locationHistoryProvider = StreamProvider<List<LocationPoint>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.locationPoints)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
        ..limit(500))
      .watch();
});
