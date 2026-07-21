import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/platform/location/geofence_service.dart';

// Drift round-trips DateTimes through a local, not UTC, unix timestamp —
// comparing with `==` would fail across a non-UTC timezone even though
// the instant is identical, since DateTime's `==` also checks `isUtc`.
Matcher sameMoment(DateTime expected) => predicate<DateTime>(
  (actual) => actual.isAtSameMomentAs(expected),
  'is at the same moment as $expected',
);

void main() {
  late AppDatabase db;
  late GeofenceService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = GeofenceService(db);
  });

  tearDown(() => db.close());

  Future<String> insertPlace({
    double latitude = 51.5,
    double longitude = -0.12,
    double radiusMeters = 100,
    bool currentlyInside = false,
  }) async {
    final place = await db
        .into(db.places)
        .insertReturning(
          PlacesCompanion.insert(
            name: 'Home',
            latitude: latitude,
            longitude: longitude,
            radiusMeters: Value(radiusMeters),
            currentlyInside: Value(currentlyInside),
            source: RecordSource.manual,
          ),
        );
    return place.id;
  }

  Future<Place> reload(String id) async =>
      (db.select(db.places)..where((t) => t.id.equals(id))).getSingle();

  test('marks a place entered when a point lands inside its radius', () async {
    final id = await insertPlace();
    final now = DateTime.utc(2026, 1, 1, 12);

    await service.checkTransitions(
      latitude: 51.5,
      longitude: -0.12,
      recordedAt: now,
    );

    final place = await reload(id);
    expect(place.currentlyInside, isTrue);
    expect(place.lastEnteredAt, sameMoment(now));
    expect(place.lastExitedAt, isNull);
    expect(place.stateAsOf, sameMoment(now));
  });

  test('marks a place exited when a point lands outside its radius', () async {
    final enteredAt = DateTime.utc(2026, 1, 1, 12);
    final id = await insertPlace(currentlyInside: true);
    await (db.update(db.places)..where((t) => t.id.equals(id))).write(
      PlacesCompanion(
        lastEnteredAt: Value(enteredAt),
        stateAsOf: Value(enteredAt),
      ),
    );
    final exitedAt = DateTime.utc(2026, 1, 1, 13);

    // ~1.1km away — well outside the default 100m radius.
    await service.checkTransitions(
      latitude: 51.51,
      longitude: -0.12,
      recordedAt: exitedAt,
    );

    final place = await reload(id);
    expect(place.currentlyInside, isFalse);
    expect(place.lastEnteredAt, sameMoment(enteredAt));
    expect(place.lastExitedAt, sameMoment(exitedAt));
    expect(place.stateAsOf, sameMoment(exitedAt));
  });

  test('treats a point exactly on the radius boundary as inside', () async {
    // 1 degree of longitude at the equator is ~111,320m; a tiny fraction
    // gets us close enough to a known distance without a helper.
    final id = await insertPlace(
      latitude: 0,
      longitude: 0,
      radiusMeters: 111320,
    );

    await service.checkTransitions(
      latitude: 0,
      longitude: 1,
      recordedAt: DateTime.utc(2026, 1, 1),
    );

    expect((await reload(id)).currentlyInside, isTrue);
  });

  test('does not touch state when the point stays in the same zone', () async {
    final id = await insertPlace();
    final firstFix = DateTime.utc(2026, 1, 1, 12);
    await service.checkTransitions(
      latitude: 51.5,
      longitude: -0.12,
      recordedAt: firstFix,
    );

    final secondFix = DateTime.utc(2026, 1, 1, 12, 5);
    await service.checkTransitions(
      latitude: 51.5001,
      longitude: -0.12,
      recordedAt: secondFix,
    );

    final place = await reload(id);
    // Still inside on both fixes — lastEnteredAt/stateAsOf must not be
    // bumped by the second, no-op fix.
    expect(place.lastEnteredAt, sameMoment(firstFix));
    expect(place.stateAsOf, sameMoment(firstFix));
  });

  test('ignores out-of-order points older than the last known state', () async {
    final id = await insertPlace();
    final stateAsOf = DateTime.utc(2026, 1, 1, 12);
    await service.checkTransitions(
      latitude: 51.5,
      longitude: -0.12,
      recordedAt: stateAsOf,
    );

    // A late-arriving, older point claiming to be outside must not
    // clobber the newer "inside" state.
    await service.checkTransitions(
      latitude: 51.51,
      longitude: -0.12,
      recordedAt: stateAsOf.subtract(const Duration(minutes: 5)),
    );

    final place = await reload(id);
    expect(place.currentlyInside, isTrue);
    expect(place.stateAsOf, sameMoment(stateAsOf));
  });

  test('ignores soft-deleted places', () async {
    final id = await insertPlace();
    await (db.update(db.places)..where((t) => t.id.equals(id))).write(
      PlacesCompanion(deletedAt: Value(DateTime.utc(2026, 1, 1))),
    );

    await service.checkTransitions(
      latitude: 51.5,
      longitude: -0.12,
      recordedAt: DateTime.utc(2026, 1, 2),
    );

    final place = await reload(id);
    expect(place.currentlyInside, isFalse);
    expect(place.stateAsOf, isNull);
  });
}
