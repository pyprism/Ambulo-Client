import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database_provider.dart';
import '../../data/local/tables/location_points_table.dart';
import '../../features/tracking/monitoring_mode_controller.dart';
import '../../features/tracking/tracking_pause_controller.dart';
import 'step_tracking_service.dart';

/// Steps respect the monitoring mode like location does: off in Quit and
/// Manual (no passive sensor listening), on in Significant/Move — and, like
/// location, forced off by the incognito pause toggle regardless of mode.
final stepTrackingServiceProvider = Provider<StepTrackingService>((ref) {
  final service = StepTrackingService(ref.watch(appDatabaseProvider));

  void applyEffectiveState() {
    final paused = ref.read(trackingPausedProvider);
    final mode = ref.read(monitoringModeProvider);
    final shouldRun =
        !paused &&
        (mode == MonitoringMode.significant || mode == MonitoringMode.move);
    if (shouldRun) {
      service.start();
    } else {
      service.stop();
    }
  }

  ref.listen<MonitoringMode>(
    monitoringModeProvider,
    (previous, next) => applyEffectiveState(),
  );
  ref.listen<bool>(
    trackingPausedProvider,
    (previous, next) => applyEffectiveState(),
  );

  // See location_tracking_provider.dart: both controllers report a
  // provisional default (quit/false) before their persisted value loads,
  // so the very first apply must wait for both to actually be ready.
  Future.wait([
    ref.read(monitoringModeProvider.notifier).ready,
    ref.read(trackingPausedProvider.notifier).ready,
  ]).then((_) => applyEffectiveState());

  ref.onDispose(service.stop);
  return service;
});
