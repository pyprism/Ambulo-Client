// Proves the fix for a startup race: MonitoringModeController and
// TrackingPauseController both report a synchronous default (quit / not
// paused) before their persisted SharedPreferences value loads. Anything
// that applies that default straight to a real sensor/service — as
// `location_tracking_provider.dart` and `step_tracking_provider.dart` do —
// must wait for the real restored value first, or a persisted incognito
// pause could be raced by a moment of live tracking on app start.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/features/tracking/monitoring_mode_controller.dart';
import 'package:ambulo/features/tracking/tracking_pause_controller.dart';

void main() {
  test(
    'TrackingPauseController reports the synchronous default before '
    'restore, and the persisted value only after `ready`',
    () async {
      SharedPreferences.setMockInitialValues({'tracking_paused': true});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(trackingPausedProvider), isFalse);

      await container.read(trackingPausedProvider.notifier).ready;

      expect(container.read(trackingPausedProvider), isTrue);
    },
  );

  test(
    'MonitoringModeController reports the synchronous default before '
    'restore, and the persisted value only after `ready`',
    () async {
      SharedPreferences.setMockInitialValues({'monitoring_mode': 'move'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(monitoringModeProvider), MonitoringMode.quit);

      await container.read(monitoringModeProvider.notifier).ready;

      expect(container.read(monitoringModeProvider), MonitoringMode.move);
    },
  );

  test(
    'a mode/pause apply gated on both `ready` futures (the pattern used by '
    'the real location/step service providers) only fires once, with the '
    'restored values — never with the provisional quit/unpaused default',
    () async {
      SharedPreferences.setMockInitialValues({
        'tracking_paused': true,
        'monitoring_mode': 'move',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final applied = <(bool, MonitoringMode)>[];
      Future.wait([
        container.read(monitoringModeProvider.notifier).ready,
        container.read(trackingPausedProvider.notifier).ready,
      ]).then((_) {
        applied.add((
          container.read(trackingPausedProvider),
          container.read(monitoringModeProvider),
        ));
      });

      // Nothing applied yet — still waiting on the persisted values.
      expect(applied, isEmpty);

      await container.read(trackingPausedProvider.notifier).ready;
      await container.read(monitoringModeProvider.notifier).ready;
      // Let the `.then` callback's microtask run.
      await Future<void>.delayed(Duration.zero);

      expect(applied, hasLength(1));
      expect(applied.single, (true, MonitoringMode.move));
    },
  );
}
