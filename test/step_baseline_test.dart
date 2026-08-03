import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/platform/fitness/step_tracking_service.dart';

void main() {
  group('rolloverBaseline', () {
    final today = DateTime(2026, 8, 2, 9);
    final lastNight = DateTime(2026, 8, 1, 22, 30);

    test("credits steps walked before the day's first app launch", () {
      // Counter was at 12000 when the app was last seen at 22:30; the user
      // then walked 3000 steps this morning with the process dead. Anchoring
      // to the current reading would report 0 for that walk.
      expect(
        rolloverBaseline(
          counter: 15000,
          lastCounter: 12000,
          lastSeenAt: lastNight,
          today: today,
        ),
        12000,
      );
    });

    test('still carries forward from an afternoon sighting the day before', () {
      // People don't reliably open a tracking app late at night — a window
      // measured in a few hours would miss the case this fixes.
      expect(
        rolloverBaseline(
          counter: 15000,
          lastCounter: 12000,
          lastSeenAt: DateTime(2026, 8, 1, 12),
          today: today,
        ),
        12000,
      );
    });

    test('falls back once the last sighting is too far before midnight', () {
      expect(
        rolloverBaseline(
          counter: 15000,
          lastCounter: 12000,
          // 16h before midnight — no telling which side of it the
          // unattributed steps fall on.
          lastSeenAt: DateTime(2026, 8, 1, 8),
          today: today,
        ),
        isNull,
      );
    });

    test('falls back after a reboot reset the counter', () {
      expect(
        rolloverBaseline(
          counter: 400,
          lastCounter: 12000,
          lastSeenAt: lastNight,
          today: today,
        ),
        isNull,
      );
    });

    test('falls back on a first-ever run with nothing recorded', () {
      expect(
        rolloverBaseline(
          counter: 15000,
          lastCounter: null,
          lastSeenAt: null,
          today: today,
        ),
        isNull,
      );
    });

    test(
      'carries forward when the last sighting is already on the new day',
      () {
        expect(
          rolloverBaseline(
            counter: 15000,
            lastCounter: 14000,
            lastSeenAt: DateTime(2026, 8, 2, 7),
            today: today,
          ),
          14000,
        );
      },
    );
  });

  group('StepTrackingService.resolveRolloverBaseline', () {
    late AppDatabase db;

    StepTrackingService serviceWith(Future<int?> Function() healthConnect) {
      return StepTrackingService(
        db,
        deviceId: () async => 'device-1',
        healthConnectSteps: (_, _) => healthConnect(),
      );
    }

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('anchors exactly to what Health Connect already recorded today', () {
      // 3000 of the counter's steps happened today, so "0 today" is 12000 —
      // this morning's walk survives the rollover instead of being dropped.
      final service = serviceWith(() async => 3000);
      expect(
        service.resolveRolloverBaseline(15000, DateTime(2026, 8, 2, 9)),
        completion(12000),
      );
    });

    test('anchors at zero when Health Connect implies a reboot today', () {
      // More steps today than the counter has since boot ⇒ boot happened
      // after midnight ⇒ everything the counter holds belongs to today.
      final service = serviceWith(() async => 5000);
      expect(
        service.resolveRolloverBaseline(3000, DateTime(2026, 8, 2, 9)),
        completion(0),
      );
    });

    test('falls back to the heuristic when Health Connect cannot answer', () {
      SharedPreferences.setMockInitialValues({
        'pedometer_last_counter': 12000,
        'pedometer_last_counter_seen_at_ms': DateTime(
          2026,
          8,
          1,
          22,
          30,
        ).millisecondsSinceEpoch,
      });
      final service = serviceWith(() async => null);
      expect(
        service.resolveRolloverBaseline(15000, DateTime(2026, 8, 2, 9)),
        completion(12000),
      );
    });

    test('falls back to the heuristic when Health Connect throws', () {
      SharedPreferences.setMockInitialValues({
        'pedometer_last_counter': 12000,
        'pedometer_last_counter_seen_at_ms': DateTime(
          2026,
          8,
          1,
          22,
          30,
        ).millisecondsSinceEpoch,
      });
      final service = serviceWith(() async => throw StateError('no grant'));
      expect(
        service.resolveRolloverBaseline(15000, DateTime(2026, 8, 2, 9)),
        completion(12000),
      );
    });

    test('anchors to the raw counter when nothing can answer', () {
      final service = serviceWith(() async => null);
      expect(
        service.resolveRolloverBaseline(15000, DateTime(2026, 8, 2, 9)),
        completion(15000),
      );
    });
  });
}
