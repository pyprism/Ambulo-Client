import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database_provider.dart';
import '../../data/repositories/device_repository.dart';
import '../../features/fitness/fitness_providers.dart';
import '../../features/timeline/trip_history_provider.dart';
import '../../features/tracking/tracking_pause_controller.dart';
import 'step_tracking_service.dart';

/// Result of the most recent [StepTrackingService.start] attempt — lets
/// Settings/Diagnostics explain *why* steps aren't counting (mirrors
/// `locationTrackingStatusProvider`).
class StepTrackingStatusController extends Notifier<StepTrackingStatus> {
  @override
  StepTrackingStatus build() => StepTrackingStatus.inactive;

  void report(StepTrackingStatus status) => state = status;
}

final stepTrackingStatusProvider =
    NotifierProvider<StepTrackingStatusController, StepTrackingStatus>(
      StepTrackingStatusController.new,
    );

/// Unlike location, steps run continuously regardless of monitoring mode —
/// the step-counter sensor is a hardware-batched, low-power counter (not a
/// radio), so it doesn't carry GPS's battery cost. Still forced off by the
/// incognito pause toggle, same as location.
final stepTrackingServiceProvider = Provider<StepTrackingService>((ref) {
  final service = StepTrackingService(
    ref.watch(appDatabaseProvider),
    deviceId: () async =>
        (await ref.read(deviceRepositoryProvider).ensureLocalDevice()).id,
    onUpdate: () {
      ref.invalidate(todayStatsProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(monthlyStatsProvider);
      ref.invalidate(todayTripTimeMinutesProvider);
    },
  );

  Future<void> applyEffectiveState() async {
    final paused = ref.read(trackingPausedProvider);
    final status = paused
        ? await service.stop().then((_) => StepTrackingStatus.inactive)
        : await service.start();
    ref.read(stepTrackingStatusProvider.notifier).report(status);
  }

  ref.listen<bool>(
    trackingPausedProvider,
    (previous, next) => applyEffectiveState(),
  );

  // See location_tracking_provider.dart: the pause controller reports a
  // provisional `false` before its persisted value loads, so the very
  // first apply must wait for the real restored value.
  ref
      .read(trackingPausedProvider.notifier)
      .ready
      .then((_) => applyEffectiveState());

  ref.onDispose(service.stop);
  return service;
});
