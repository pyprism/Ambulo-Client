import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/tables/sync_columns.dart';
import 'trip_history_provider.dart';

/// The location points that make up a single trip's route, for the trip
/// detail screen's mini-map and max-speed calc. Prefers points tagged with
/// this trip's id (see `LocationTrackingService._store`); falls back to the
/// old time-window query — restricted to `source == location` to at least
/// exclude manual fixes — for trips recorded before the tripId column
/// existed (untagged rows, including ones synced in from another device
/// on an older client build). Empty (not an error) while the trip itself
/// is still loading or doesn't exist.
///
/// A single `.watch()` over both candidate sets (rather than watching the
/// tagged query and switching to a separate fallback stream) so the result
/// stays reactive for the life of the provider: an `asyncExpand`-based
/// switch would concatenate onto the non-completing fallback stream the
/// first time the tagged set is empty (e.g. a trip's very first point,
/// stored before the trip row exists) and never observe a later tagged
/// emission for that provider instance.
final tripRoutePointsProvider = StreamProvider.autoDispose
    .family<List<LocationPoint>, String>((ref, tripId) {
      final trip = ref.watch(tripByIdProvider(tripId)).value;
      if (trip == null) return const Stream<List<LocationPoint>>.empty();
      final db = ref.watch(appDatabaseProvider);

      return (db.select(db.locationPoints)
            ..where(
              (t) =>
                  t.deletedAt.isNull() &
                  (t.tripId.equals(tripId) |
                      (t.tripId.isNull() &
                          t.source.equalsValue(RecordSource.location) &
                          t.recordedAt.isBiggerOrEqualValue(trip.startedAt) &
                          (trip.endedAt == null
                              ? t.recordedAt.isSmallerThanValue(DateTime.now())
                              : t.recordedAt.isSmallerOrEqualValue(
                                  trip.endedAt!,
                                )))),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
          .watch()
          .map((rows) {
            final tagged = [
              for (final r in rows)
                if (r.tripId == tripId) r,
            ];
            return tagged.isNotEmpty ? tagged : rows;
          });
    });
