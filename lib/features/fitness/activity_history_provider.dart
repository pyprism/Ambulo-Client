import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/activity_sample_repository.dart';

/// Reactive, most-recent-first activity segment history.
final activityHistoryProvider = StreamProvider<List<ActivitySample>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.activitySamples)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(100))
      .watch();
});

/// A single activity segment by id, for the detail screen. Excludes
/// tombstones — a delete synced in from another device must hide it here
/// too, not just in the list.
final activitySampleByIdProvider = StreamProvider.autoDispose
    .family<ActivitySample?, String>((ref, id) {
      final db = ref.watch(appDatabaseProvider);
      return (db.select(db.activitySamples)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .watchSingleOrNull();
    });

final activitySampleRepositoryProvider = Provider<ActivitySampleRepository>((
  ref,
) {
  return ActivitySampleRepository(ref.watch(appDatabaseProvider));
});
