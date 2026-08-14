// plausibleSpeedsMps must drop points whose accuracy fields signal GPS
// noise, but let legacy rows (recorded before the v6 schema bump, so both
// accuracy columns are null) pass through unfiltered.
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/features/timeline/plausible_speed.dart';

LocationPoint _point({
  required String id,
  double? speed,
  double? horizontalAccuracy,
  double? speedAccuracy,
}) {
  final now = DateTime.now();
  return LocationPoint(
    id: id,
    createdAt: now,
    updatedAt: now,
    localRev: 1,
    syncState: SyncState.synced,
    source: RecordSource.location,
    latitude: 52.0,
    longitude: 13.0,
    speed: speed,
    horizontalAccuracy: horizontalAccuracy,
    speedAccuracy: speedAccuracy,
    recordedAt: now,
    connectivity: Connectivity.unknown,
    monitoringMode: MonitoringMode.move,
  );
}

void main() {
  test('drops points with no speed reading', () {
    final points = [_point(id: '1', speed: null)];
    expect(plausibleSpeedsMps(points), isEmpty);
  });

  test('drops points with poor horizontal accuracy', () {
    final points = [
      _point(id: '1', speed: 5.0, horizontalAccuracy: 51, speedAccuracy: 1),
    ];
    expect(plausibleSpeedsMps(points), isEmpty);
  });

  test('drops points with poor speed accuracy', () {
    final points = [
      _point(id: '1', speed: 5.0, horizontalAccuracy: 10, speedAccuracy: 2.1),
    ];
    expect(plausibleSpeedsMps(points), isEmpty);
  });

  test('keeps points at the accuracy thresholds', () {
    final points = [
      _point(id: '1', speed: 5.0, horizontalAccuracy: 50, speedAccuracy: 2),
    ];
    expect(plausibleSpeedsMps(points), [5.0]);
  });

  test('keeps legacy rows (recorded before v6) where both accuracy columns are '
      'null, regardless of speed value', () {
    final points = [
      _point(
        id: '1',
        speed: 40.0,
        horizontalAccuracy: null,
        speedAccuracy: null,
      ),
    ];
    expect(plausibleSpeedsMps(points), [40.0]);
  });

  test('mixed batch: only the plausible speeds survive, order preserved', () {
    final points = [
      _point(id: '1', speed: 3.0, horizontalAccuracy: 10, speedAccuracy: 0.5),
      _point(id: '2', speed: 30.0, horizontalAccuracy: 200, speedAccuracy: 0.5),
      _point(id: '3', speed: null, horizontalAccuracy: 10, speedAccuracy: 0.5),
      _point(
        id: '4',
        speed: 4.0,
        horizontalAccuracy: null,
        speedAccuracy: null,
      ),
    ];
    expect(plausibleSpeedsMps(points), [3.0, 4.0]);
  });
}
