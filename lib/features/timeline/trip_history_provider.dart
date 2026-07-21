import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/trip_repository.dart';

/// Reactive, most-recent-first trip history for the timeline (and the map's
/// trip panel). `range == null` is the original unfiltered/capped view;
/// non-null narrows to trips starting in that range. `autoDispose` because,
/// unlike the old single kept-alive provider, each distinct filter range
/// picked in the UI is its own drift `.watch()` subscription — this lets one
/// close once nothing's watching it instead of accumulating forever.
final tripHistoryProvider = StreamProvider.autoDispose
    .family<List<Trip>, DateTimeRange?>((ref, range) {
      final db = ref.watch(appDatabaseProvider);
      final query = db.select(db.trips)..where((t) => t.deletedAt.isNull());
      if (range != null) {
        query.where(
          (t) =>
              t.startedAt.isBiggerOrEqualValue(range.start) &
              t.startedAt.isSmallerThanValue(range.end),
        );
      }
      query.orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
      if (range == null) query.limit(200);
      return query.watch();
    });

/// A single trip by id, for the detail screen. Excludes tombstones — a
/// delete synced in from another device must hide the trip here too, not
/// just in the list (same bug class as the weight-`HealthSample` fix).
final tripByIdProvider = StreamProvider.autoDispose.family<Trip?, String>((
  ref,
  id,
) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.trips,
  )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).watchSingleOrNull();
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(ref.watch(appDatabaseProvider));
});

/// Today's total trip time (door-to-door, including stops/driving) — the
/// same definition Timeline's `TripTile` shows, as opposed to Dashboard's
/// "Active minutes" (walking/running/cycling only). Each trip is clipped to
/// today's window the same way `FitnessStatsRepository.statsForDay` clips
/// activity segments, so a trip that started yesterday (or is still
/// ongoing, spanning midnight) is credited only for today's portion.
final todayTripTimeMinutesProvider = Provider<int>((ref) {
  final trips = ref.watch(tripHistoryProvider(null)).value ?? const [];
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  var totalSeconds = 0;
  for (final trip in trips) {
    final tripEnd = trip.endedAt ?? now;
    final clippedStart = trip.startedAt.isBefore(todayStart)
        ? todayStart
        : trip.startedAt;
    final clippedEnd = tripEnd.isAfter(todayEnd) ? todayEnd : tripEnd;
    if (clippedEnd.isAfter(clippedStart)) {
      totalSeconds += clippedEnd.difference(clippedStart).inSeconds;
    }
  }
  return totalSeconds ~/ 60;
});
