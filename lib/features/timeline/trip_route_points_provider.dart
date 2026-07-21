import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import 'trip_history_provider.dart';

/// The location points that make up a single trip's route, for the trip
/// detail screen's mini-map. Empty (not an error) while the trip itself is
/// still loading or doesn't exist.
final tripRoutePointsProvider = StreamProvider.autoDispose
    .family<List<LocationPoint>, String>((ref, tripId) {
      final trip = ref.watch(tripByIdProvider(tripId)).value;
      if (trip == null) return const Stream<List<LocationPoint>>.empty();
      final db = ref.watch(appDatabaseProvider);
      return (db.select(db.locationPoints)
            ..where(
              (t) =>
                  t.recordedAt.isBiggerOrEqualValue(trip.startedAt) &
                  (trip.endedAt == null
                      ? t.recordedAt.isSmallerThanValue(DateTime.now())
                      : t.recordedAt.isSmallerOrEqualValue(trip.endedAt!)) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
          .watch();
    });
