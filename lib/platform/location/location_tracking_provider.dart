import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database_provider.dart';
import '../../data/local/tables/location_points_table.dart';
import '../../features/tracking/monitoring_mode_controller.dart';
import '../../features/tracking/tracking_pause_controller.dart';
import 'location_tracking_service.dart';

/// Result of the most recent attempt to apply the effective monitoring
/// mode — lets Settings/Diagnostics explain *why* tracking isn't running
/// (denied permission, background permission needed, location off) instead
/// of it silently not happening.
class LocationTrackingStatusController
    extends Notifier<LocationTrackingStatus> {
  @override
  LocationTrackingStatus build() => LocationTrackingStatus.inactive;

  void report(LocationTrackingStatus status) => state = status;
}

final locationTrackingStatusProvider =
    NotifierProvider<LocationTrackingStatusController, LocationTrackingStatus>(
      LocationTrackingStatusController.new,
    );

/// Watching this provider anywhere keeps the service alive for the app's
/// lifetime and reacts to every monitoring-mode change (including the
/// current mode immediately on first read) and to the incognito pause
/// toggle, which forces Quit regardless of the selected mode without
/// changing that underlying setting.
final locationTrackingServiceProvider = Provider<LocationTrackingService>((
  ref,
) {
  final service = LocationTrackingService(ref.watch(appDatabaseProvider));

  Future<void> applyEffectiveMode() async {
    final paused = ref.read(trackingPausedProvider);
    final mode = ref.read(monitoringModeProvider);
    final status = await service.applyMode(paused ? MonitoringMode.quit : mode);
    ref.read(locationTrackingStatusProvider.notifier).report(status);
  }

  ref.listen<MonitoringMode>(
    monitoringModeProvider,
    (previous, next) => applyEffectiveMode(),
  );
  ref.listen<bool>(
    trackingPausedProvider,
    (previous, next) => applyEffectiveMode(),
  );

  // Both controllers report `quit`/`false` synchronously before their
  // persisted value loads from SharedPreferences — applying that
  // provisional default straight to a real sensor stream would briefly
  // start (or fail to pause) tracking. Wait for the real restored values
  // before the very first apply; later reactive applies above don't need
  // this since `ready` has long since resolved by then.
  Future.wait([
    ref.read(monitoringModeProvider.notifier).ready,
    ref.read(trackingPausedProvider.notifier).ready,
  ]).then((_) => applyEffectiveMode());

  ref.onDispose(service.dispose);
  return service;
});
