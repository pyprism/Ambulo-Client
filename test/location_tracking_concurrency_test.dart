import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/platform/location/location_tracking_service.dart';

/// Emits a scripted list of positions with realistic spacing between them,
/// so each async stream callback finishes before the next point arrives
/// (matching how the OS delivers points seconds apart, not back-to-back).
class _MockGeolocator extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  _MockGeolocator(this.points);
  final List<Position> points;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) async* {
    for (final p in points) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      yield p;
    }
  }
}

Position _p(double lat, double lon, DateTime ts, double speed) => Position(
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

  List<Position> walk() {
    // 6 points ~11m apart, walking speed, 10s apart in wall-clock time.
    final t0 = DateTime.now().subtract(const Duration(minutes: 10));
    return [
      for (var i = 0; i < 6; i++)
        _p(52.0 + i * 0.0001, 13.0, t0.add(Duration(seconds: i * 10)), 1.4),
    ];
  }

  Future<void> drain() => Future<void>.delayed(const Duration(seconds: 1));

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('a single Move session records one segment with accrued distance',
      () async {
    GeolocatorPlatform.instance = _MockGeolocator(walk());
    final service = LocationTrackingService(db);

    await service.applyMode(MonitoringMode.move);
    await drain();

    final points = await db.select(db.locationPoints).get();
    final segments = await db.select(db.activitySamples).get();

    expect(points.length, 6);
    expect(segments.length, 1);
    expect(segments.single.distanceMeters, greaterThan(0));
    expect(segments.single.endedAt, isNotNull);

    await service.dispose();
  });

  test(
    'concurrent applyMode at startup does not leak a second parallel stream',
    () async {
      // Reproduces the startup race: the provider fires an apply from the
      // monitoring-mode/pause `ref.listen`s (during their controllers'
      // restore) *and* from the ready-gated apply. Before the service
      // serialized its mutations, both opened a stream — 12 points, racing
      // segments all stuck at 0 distance. It must now collapse to one stream.
      GeolocatorPlatform.instance = _MockGeolocator(walk());
      final service = LocationTrackingService(db);

      await Future.wait([
        service.applyMode(MonitoringMode.move),
        service.applyMode(MonitoringMode.move),
      ]);
      await drain();

      final points = await db.select(db.locationPoints).get();
      final segments = await db.select(db.activitySamples).get();

      expect(points.length, 6, reason: 'exactly one stream, not two');
      expect(segments.length, 1);
      expect(segments.single.distanceMeters, greaterThan(0));

      await service.dispose();
    },
  );
}
