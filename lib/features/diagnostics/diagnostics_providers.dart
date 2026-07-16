import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as conn_plus;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;

import '../../core/network/dio_client.dart';
import '../../data/local/tables/location_points_table.dart';
import '../../platform/location/location_tracking_provider.dart';
import '../../platform/platform_support.dart';
import '../sync/sync_controller.dart';
import '../tracking/monitoring_mode_controller.dart';
import '../tracking/tracking_pause_controller.dart';

class DiagnosticsSnapshot {
  DiagnosticsSnapshot({
    required this.monitoringMode,
    required this.isPaused,
    required this.trackingActive,
    required this.locationServiceEnabled,
    required this.locationPermission,
    required this.batterySaveMode,
    required this.connectivity,
    required this.pending,
    required this.failed,
    required this.conflicts,
    required this.lastSyncAt,
  });

  final MonitoringMode monitoringMode;
  final bool isPaused;
  final bool trackingActive;
  final bool locationServiceEnabled;
  final LocationPermission locationPermission;
  final bool batterySaveMode;
  final List<conn_plus.ConnectivityResult> connectivity;
  final int pending;
  final int failed;
  final int conflicts;
  final DateTime? lastSyncAt;
}

final diagnosticsSnapshotProvider =
    FutureProvider.autoDispose<DiagnosticsSnapshot>((ref) async {
      final mode = ref.watch(monitoringModeProvider);
      final paused = ref.watch(trackingPausedProvider);
      final syncCounts = await ref.watch(syncControllerProvider.future);

      var serviceEnabled = false;
      var permission = LocationPermission.unableToDetermine;
      var batterySaveMode = false;
      var trackingActive = false;
      if (PlatformSupport.supportsSensorCollection) {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        permission = await Geolocator.checkPermission();
        try {
          batterySaveMode = await Battery().isInBatterySaveMode;
        } catch (_) {
          batterySaveMode = false;
        }
        trackingActive = ref.read(locationTrackingServiceProvider).isActive;
      }
      final connectivity = await conn_plus.Connectivity().checkConnectivity();

      return DiagnosticsSnapshot(
        monitoringMode: mode,
        isPaused: paused,
        trackingActive: trackingActive,
        locationServiceEnabled: serviceEnabled,
        locationPermission: permission,
        batterySaveMode: batterySaveMode,
        connectivity: connectivity,
        pending: syncCounts.pending,
        failed: syncCounts.failed,
        conflicts: syncCounts.conflicts,
        lastSyncAt: syncCounts.lastSyncAt,
      );
    });

class ConnectivityTestResult {
  ConnectivityTestResult({required this.reachable, this.latencyMs, this.error});
  final bool reachable;
  final int? latencyMs;
  final String? error;
}

Future<ConnectivityTestResult> testServerConnection(Dio dio) async {
  final stopwatch = Stopwatch()..start();
  try {
    final response = await dio.get('/api/healthz/');
    stopwatch.stop();
    return ConnectivityTestResult(
      reachable: response.statusCode == 200,
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  } on DioException catch (e) {
    stopwatch.stop();
    return ConnectivityTestResult(reachable: false, error: describeDioError(e));
  }
}
