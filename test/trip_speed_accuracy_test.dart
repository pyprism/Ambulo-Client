// Trip duration must exclude the stationary tail before a trip auto-splits,
// and stationary jitter shouldn't inflate distance. Also covers
// stream-recorded points getting tagged with the trip they belong to.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/platform/location/geo_math.dart';
import 'package:ambulo/platform/location/location_tracking_service.dart';

class _MockGeolocator extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  _MockGeolocator(this.points, {Position? manualPosition})
    : manualPosition = manualPosition ?? points.first;
  final List<Position> points;
  final Position manualPosition;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => manualPosition;

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) async* {
    for (final p in points) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      yield p;
    }
  }
}

// DateTimeColumn is stored as whole unix seconds, so a `DateTime.now()`-based
// timestamp with sub-second precision doesn't round-trip — truncate before
// comparing against a value read back from the database.
DateTime _sec(DateTime dt) => DateTime.fromMillisecondsSinceEpoch(
  (dt.millisecondsSinceEpoch ~/ 1000) * 1000,
);

Position _p(double lat, double lon, DateTime ts, {double speed = 1.4}) =>
    Position(
      latitude: lat,
      longitude: lon,
      timestamp: ts,
      accuracy: 5.0,
      altitude: 10.0,
      altitudeAccuracy: 3.0,
      heading: 90.0,
      headingAccuracy: 5.0,
      speed: speed,
      speedAccuracy: 0.5,
    );

void main() {
  late AppDatabase db;

  Future<void> drain() => Future<void>.delayed(const Duration(seconds: 1));

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('trip closed by a stationary gap ends at the last movement time, not '
      'the point that triggered the close — trimming the 20-min tail out of '
      'the reported duration', () async {
    final movementEnd = _sec(DateTime.now().subtract(const Duration(hours: 1)));
    final points = [
      // Each step is ~66m — past the 50m stationary radius, so the
      // anchor (and _lastMovementAt) actually advances with the walk
      // instead of staying pinned to the first point.
      _p(52.0000, 13.0, movementEnd.subtract(const Duration(seconds: 20))),
      _p(52.0006, 13.0, movementEnd.subtract(const Duration(seconds: 10))),
      _p(52.0012, 13.0, movementEnd),
      // Sit still at the same spot for 21 minutes — beyond
      // _tripStationaryGap — which must close the trip stamped at
      // `movementEnd`, not at this point's timestamp.
      _p(52.0012, 13.0, movementEnd.add(const Duration(minutes: 21))),
    ];
    GeolocatorPlatform.instance = _MockGeolocator(points);
    final service = LocationTrackingService(db);

    await service.applyMode(MonitoringMode.move);
    await drain();

    final trips = await db.select(db.trips).get();
    expect(trips.length, 1);
    expect(trips.single.endedAt, movementEnd);

    await service.dispose();
  });

  test('a trip whose creating point never reset the stationary anchor '
      'cannot close with endedAt before startedAt', () async {
    // P0 anchors _stationaryAnchor/_lastMovementAt. P1 is the point whose
    // ~15m delta creates the trip (startedAt = P1.time) — but 15m is still
    // inside P0's 50m stationary radius, so the anchor (and
    // _lastMovementAt) stay pinned at P0.time, which is *before*
    // startedAt. A dwell near P0 for >= 20 min then closes the trip with
    // endedAt = _lastMovementAt = P0.time — earlier than startedAt —
    // unless _closeCurrentTrip clamps it.
    final t0 = _sec(DateTime.now().subtract(const Duration(hours: 1)));
    final points = [
      _p(52.0, 13.0, t0),
      _p(52.00014, 13.0, t0.add(const Duration(seconds: 10))), // ~15.5m
      _p(
        52.00001,
        13.0,
        t0.add(const Duration(minutes: 21)),
        speed: 0.1,
      ), // dwell near P0
    ];
    GeolocatorPlatform.instance = _MockGeolocator(points);
    final service = LocationTrackingService(db);

    await service.applyMode(MonitoringMode.move);
    await drain();

    final trips = await db.select(db.trips).get();
    expect(trips.length, 1);
    final trip = trips.single;
    expect(trip.startedAt, points[1].timestamp);
    expect(
      trip.endedAt!.isBefore(trip.startedAt),
      isFalse,
      reason: 'endedAt must never precede startedAt',
    );
    expect(trip.endedAt, trip.startedAt);

    await service.dispose();
  });

  test(
    'trip closed by applyMode/dispose (tracking stopped mid-movement) keeps '
    'ending at the last recorded point — current behavior, unchanged',
    () async {
      final t0 = _sec(DateTime.now().subtract(const Duration(minutes: 5)));
      final points = [
        _p(52.0, 13.0, t0),
        _p(52.0002, 13.0, t0.add(const Duration(seconds: 10))),
        _p(52.0004, 13.0, t0.add(const Duration(seconds: 20))),
      ];
      GeolocatorPlatform.instance = _MockGeolocator(points);
      final service = LocationTrackingService(db);

      await service.applyMode(MonitoringMode.move);
      await drain();
      await service.applyMode(MonitoringMode.quit);

      final trips = await db.select(db.trips).get();
      expect(trips.length, 1);
      expect(trips.single.endedAt, points.last.timestamp);

      await service.dispose();
    },
  );

  test('points recorded while stationary inside the anchor radius do not grow '
      'trip.distanceMeters, pointCount, or endedAt', () async {
    final t0 = _sec(DateTime.now().subtract(const Duration(minutes: 10)));
    final lastMoveAt = t0.add(const Duration(seconds: 20));
    final points = [
      // Each step is ~66m — past the 50m stationary radius — so the trip
      // is created and extended normally, landing the anchor at the
      // walk's last point.
      _p(52.0000, 13.0, t0),
      _p(52.0006, 13.0, t0.add(const Duration(seconds: 10))),
      _p(52.0012, 13.0, lastMoveAt),
      // Jitter within 50m of that anchor, well past _stationaryJitterGap
      // (2 min) — long enough to be a genuine dwell rather than "still
      // crossing the anchor radius" — must not bump distance, pointCount,
      // or endedAt even though it's within the trip-closing gap window.
      _p(
        52.00121,
        13.00001,
        lastMoveAt.add(const Duration(minutes: 3)),
        speed: 0.1,
      ),
      _p(
        52.00119,
        13.00002,
        lastMoveAt.add(const Duration(minutes: 3, seconds: 10)),
        speed: 0.1,
      ),
    ];
    GeolocatorPlatform.instance = _MockGeolocator(points);
    final service = LocationTrackingService(db);

    await service.applyMode(MonitoringMode.move);
    await drain();

    final trips = await db.select(db.trips).get();
    expect(trips.length, 1);
    // The trip is created on p1 (delta from p0 crosses the start-movement
    // threshold) — creation itself doesn't add a delta, but back-tags both
    // p0 and p1 (the untagged backlog at that point), so pointCount starts
    // at 2. p2 then extends the trip normally, adding its delta from p1 and
    // bumping pointCount to 3. The two jitter points after that are
    // stationary and don't touch distance/pointCount/endedAt.
    final expectedDistance = haversineMeters(52.0006, 13.0, 52.0012, 13.0);
    expect(trips.single.distanceMeters, closeTo(expectedDistance, 0.01));
    expect(trips.single.pointCount, 3);
    expect(trips.single.endedAt, lastMoveAt);

    await service.dispose();
  });

  test(
    'a continuous walk at Move-mode spacing (10m distance filter) accumulates '
    'its full distance — the stationary-jitter suppression must not eat real '
    'movement just because the anchor stays inside its 50m radius for '
    'several consecutive points',
    () async {
      final t0 = _sec(DateTime.now().subtract(const Duration(minutes: 10)));
      // 20 points, ~15m apart (just past Move mode's 10m distanceFilter),
      // 10s apart — realistic walking-pace spacing. Every step lands well
      // inside the 50m stationary radius of several previous anchors before
      // one finally resets it, which is exactly the scenario that must
      // still count as movement, not jitter.
      const stepDegrees = 0.000135; // ~15m of latitude per step
      final points = [
        for (var i = 0; i < 20; i++)
          _p(52.0 + stepDegrees * i, 13.0, t0.add(Duration(seconds: i * 10))),
      ];
      GeolocatorPlatform.instance = _MockGeolocator(points);
      final service = LocationTrackingService(db);

      await service.applyMode(MonitoringMode.move);
      await drain();

      final trips = await db.select(db.trips).get();
      expect(trips.length, 1);

      // Point[1] is the one whose delta (~15m >= _tripStartMovementMeters)
      // creates the trip — that delta isn't added on creation (see the
      // stationary-jitter test above). Every delta after must be counted —
      // not just the ~1-in-4 points where the anchor happens to reset.
      var expectedDistance = 0.0;
      for (var i = 2; i < points.length; i++) {
        expectedDistance += haversineMeters(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude,
        );
      }

      expect(
        trips.single.distanceMeters,
        closeTo(expectedDistance, expectedDistance * 0.01),
      );
      expect(trips.single.endedAt, points.last.timestamp);

      await service.dispose();
    },
  );

  test(
    'stream-recorded points carry the current trip id; manual points do not',
    () async {
      final t0 = _sec(DateTime.now().subtract(const Duration(minutes: 5)));
      final points = [
        _p(52.0, 13.0, t0),
        _p(52.0002, 13.0, t0.add(const Duration(seconds: 10))),
        _p(52.0004, 13.0, t0.add(const Duration(seconds: 20))),
      ];
      GeolocatorPlatform.instance = _MockGeolocator(points);
      final service = LocationTrackingService(db);

      await service.applyMode(MonitoringMode.move);
      await drain();

      final trips = await db.select(db.trips).get();
      expect(trips.length, 1);
      final tripId = trips.single.id;

      final locationPoints = await (db.select(
        db.locationPoints,
      )..orderBy([(t) => OrderingTerm.asc(t.recordedAt)])).get();
      // The point that establishes the trip is recorded before _updateTrip
      // creates the row, so it's stored untagged at first — but back-tagged
      // with the new trip's id the moment the trip is created, along with
      // any earlier points of the same session that were also still
      // untagged. Every point ends up carrying the trip id.
      for (final point in locationPoints) {
        expect(point.tripId, tripId);
      }
      // pointCount must reflect the back-tagged points too, not just the
      // placeholder `1` set at trip-creation time.
      expect(trips.single.pointCount, locationPoints.length);

      await service.recordManualPoint();
      final manualPoint = (await (db.select(
        db.locationPoints,
      )..where((t) => t.source.equalsValue(RecordSource.manual))).get()).single;
      expect(manualPoint.tripId, isNull);

      await service.dispose();
    },
  );

  test('a long idle dwell between two trips is not back-tagged into the '
      'second trip', () async {
    final movementEnd = _sec(DateTime.now().subtract(const Duration(hours: 3)));
    const dwellLat = 52.0012;
    final points = [
      // Creates and extends Trip A (~66m steps, past the 50m stationary
      // radius each time).
      _p(52.0000, 13.0, movementEnd.subtract(const Duration(seconds: 20))),
      _p(52.0006, 13.0, movementEnd.subtract(const Duration(seconds: 10))),
      _p(dwellLat, 13.0, movementEnd),
      // Closes Trip A: stationary at the same spot for >= 20 min.
      _p(
        dwellLat,
        13.0,
        movementEnd.add(const Duration(minutes: 21)),
        speed: 0.1,
      ),
      // Keeps idling at the same spot, well past the point where Trip A
      // already closed — this is the gap a device left alone for hours
      // between trips would produce.
      _p(
        dwellLat,
        13.0,
        movementEnd.add(const Duration(minutes: 25)),
        speed: 0.1,
      ),
      _p(
        dwellLat,
        13.0,
        movementEnd.add(const Duration(minutes: 30)),
        speed: 0.1,
      ),
      // Finally leaves, more than _tripStationaryGap (20 min) after the
      // last idle point above — far enough to also cross the trip-start
      // movement threshold in one step, creating Trip B immediately.
      _p(52.0080, 13.0, movementEnd.add(const Duration(minutes: 55))),
    ];
    GeolocatorPlatform.instance = _MockGeolocator(points);
    final service = LocationTrackingService(db);

    await service.applyMode(MonitoringMode.move);
    await drain();

    final trips = await db.select(db.trips).get();
    expect(trips.length, 2);
    final tripB = trips.reduce(
      (a, b) => a.startedAt.isAfter(b.startedAt) ? a : b,
    );
    expect(tripB.startedAt, points.last.timestamp);

    final idlePoints =
        await (db.select(db.locationPoints)..where(
              (t) =>
                  t.recordedAt.equals(points[4].timestamp) |
                  t.recordedAt.equals(points[5].timestamp),
            ))
            .get();
    expect(idlePoints, hasLength(2));
    for (final point in idlePoints) {
      // Neither idle point is anywhere near Trip B's route — tagging them
      // would stretch Trip B's polyline back through half an hour of
      // sitting still at the old trip's endpoint.
      expect(point.tripId, isNot(tripB.id));
    }

    final leavingPoint = await (db.select(
      db.locationPoints,
    )..where((t) => t.recordedAt.equals(points.last.timestamp))).getSingle();
    expect(leavingPoint.tripId, tripB.id);

    await service.dispose();
  });
}
