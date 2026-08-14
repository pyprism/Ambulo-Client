// tripRoutePointsProvider must prefer points tagged with the trip's id, and
// only fall back to the old time-window query (source == location only) for
// trips recorded before the tripId column existed.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/database_provider.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/features/timeline/trip_history_provider.dart';
import 'package:ambulo/features/timeline/trip_route_points_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> seedTrip(DateTime startedAt, DateTime endedAt) async {
    final trip = await db
        .into(db.trips)
        .insertReturning(
          TripsCompanion.insert(
            startedAt: startedAt,
            endedAt: Value(endedAt),
            source: RecordSource.location,
          ),
        );
    return trip.id;
  }

  Future<void> seedPoint({
    required DateTime recordedAt,
    String? tripId,
    RecordSource source = RecordSource.location,
  }) async {
    await db
        .into(db.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: 52.0,
            longitude: 13.0,
            recordedAt: recordedAt,
            monitoringMode: MonitoringMode.move,
            source: source,
            tripId: Value(tripId),
          ),
        );
  }

  // Both providers are autoDispose StreamProviders chained via ref.watch —
  // `container.listen` (rather than a one-shot `.future` read) keeps them
  // alive across the awaits below and through the dependency's own async
  // resolution, instead of racing autoDispose tearing them down between
  // reads.
  Future<List<LocationPoint>> watchRoutePoints(String tripId) async {
    container.listen(tripByIdProvider(tripId), (_, _) {});
    final sub = container.listen(tripRoutePointsProvider(tripId), (_, _) {});
    addTearDown(sub.close);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return container.read(tripRoutePointsProvider(tripId)).value ?? const [];
  }

  test('prefers points tagged with the trip id over the time window', () async {
    final start = DateTime.now().subtract(const Duration(minutes: 10));
    final end = DateTime.now();
    final tripId = await seedTrip(start, end);

    // Tagged with this trip.
    await seedPoint(
      recordedAt: start.add(const Duration(seconds: 5)),
      tripId: tripId,
    );
    // In the time window, but from a different trip (e.g. synced from
    // another device) — must be excluded once tagged points exist.
    await seedPoint(
      recordedAt: start.add(const Duration(seconds: 10)),
      tripId: 'other-trip',
    );

    final points = await watchRoutePoints(tripId);

    expect(points.length, 1);
    expect(points.single.tripId, tripId);
  });

  test('recovers onto tagged points after an initial empty-tagged emission — '
      'a live trip whose first point is stored before a tagged point exists '
      'must not get stuck on the fallback stream forever', () async {
    final start = DateTime.now().subtract(const Duration(minutes: 10));
    final tripId = await seedTrip(start, DateTime.now());

    // First emission: no tagged points yet, only an untagged fallback
    // candidate — the scenario an asyncExpand-based switch would latch
    // onto permanently.
    await seedPoint(recordedAt: start.add(const Duration(seconds: 5)));

    final emissions = <List<LocationPoint>>[];
    final sub = container.listen(tripRoutePointsProvider(tripId), (_, next) {
      final value = next.value;
      if (value != null) emissions.add(value);
    });
    addTearDown(sub.close);
    container.read(tripRoutePointsProvider(tripId));

    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(emissions, isNotEmpty);
    expect(emissions.last.every((p) => p.tripId == null), isTrue);

    // A tagged point now arrives (stream tracking catches up) — the
    // provider must switch to preferring it, not stay on the fallback.
    await seedPoint(
      recordedAt: start.add(const Duration(seconds: 10)),
      tripId: tripId,
    );

    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(emissions.last.length, 1);
    expect(emissions.last.single.tripId, tripId);
  });

  test(
    'falls back to the time window, restricted to source == location, for '
    'a trip with no tagged points (recorded before v6, or synced in)',
    () async {
      final start = DateTime.now().subtract(const Duration(minutes: 10));
      final end = DateTime.now();
      final tripId = await seedTrip(start, end);

      await seedPoint(recordedAt: start.add(const Duration(seconds: 5)));
      await seedPoint(
        recordedAt: start.add(const Duration(seconds: 10)),
        source: RecordSource.manual,
      );

      final points = await watchRoutePoints(tripId);

      expect(points.length, 1);
      expect(points.single.source, RecordSource.location);
    },
  );
}
