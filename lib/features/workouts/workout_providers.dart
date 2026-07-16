import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/workout_session_repository.dart';

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((
  ref,
) {
  return WorkoutSessionRepository(ref.watch(appDatabaseProvider));
});

final workoutSessionsProvider = StreamProvider<List<WorkoutSession>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.workoutSessions)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
      .watch();
});
