import 'package:connectivity_plus/connectivity_plus.dart' as conn_plus;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:intl/intl.dart';

import '../../core/network/dio_client.dart';
import '../../data/local/tables/location_points_table.dart';
import '../../platform/fitness/step_tracking_service.dart';
import '../../platform/platform_support.dart';
import '../../shared/widgets/empty_state.dart';
import 'diagnostics_providers.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  ConnectivityTestResult? _connectionTest;
  bool _testing = false;

  Future<void> _runConnectionTest() async {
    setState(() => _testing = true);
    final result = await testServerConnection(ref.read(dioProvider));
    if (!mounted) return;
    setState(() {
      _connectionTest = result;
      _testing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(diagnosticsSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(diagnosticsSnapshotProvider),
          ),
        ],
      ),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load diagnostics',
          message: '$e',
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (PlatformSupport.supportsSensorCollection) ...[
              _SectionHeader('Sensors & permissions'),
              Card(
                child: Column(
                  children: [
                    _DiagnosticTile(
                      icon: Icons.location_on_outlined,
                      label: 'Location services',
                      value: data.locationServiceEnabled
                          ? 'Enabled'
                          : 'Disabled',
                      isProblem: !data.locationServiceEnabled,
                    ),
                    const Divider(height: 1),
                    _DiagnosticTile(
                      icon: Icons.lock_outline,
                      label: 'Location permission',
                      value: _permissionLabel(data.locationPermission),
                      isProblem:
                          data.locationPermission ==
                              LocationPermission.denied ||
                          data.locationPermission ==
                              LocationPermission.deniedForever,
                    ),
                    const Divider(height: 1),
                    _DiagnosticTile(
                      icon: Icons.directions_walk_outlined,
                      label: 'Step-counting permission',
                      value: _stepStatusLabel(data.stepTrackingStatus),
                      isProblem:
                          data.stepTrackingStatus ==
                          StepTrackingStatus.permissionDenied,
                    ),
                    const Divider(height: 1),
                    _DiagnosticTile(
                      icon: Icons.battery_saver_outlined,
                      label: 'Battery saver',
                      value: data.batterySaveMode
                          ? 'On (may throttle background tracking)'
                          : 'Off',
                      isProblem: data.batterySaveMode,
                    ),
                    const Divider(height: 1),
                    _DiagnosticTile(
                      icon: Icons.sensors_outlined,
                      label: 'Tracking',
                      value: data.isPaused
                          ? 'Paused (incognito)'
                          : data.trackingActive
                          ? 'Active (${_modeLabel(data.monitoringMode)})'
                          : 'Inactive (${_modeLabel(data.monitoringMode)})',
                      isProblem: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Geolocator.openLocationSettings(),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Location settings'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Geolocator.openAppSettings(),
                    icon: const Icon(Icons.app_settings_alt_outlined),
                    label: const Text('App settings'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            _SectionHeader('Sync queue'),
            Card(
              child: Column(
                children: [
                  _DiagnosticTile(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Pending upload',
                    value: '${data.pending}',
                    isProblem: false,
                  ),
                  const Divider(height: 1),
                  _DiagnosticTile(
                    icon: Icons.error_outline,
                    label: 'Failed',
                    value: '${data.failed}',
                    isProblem: data.failed > 0,
                  ),
                  const Divider(height: 1),
                  _DiagnosticTile(
                    icon: Icons.merge_type,
                    label: 'Conflicts',
                    value: '${data.conflicts}',
                    isProblem: data.conflicts > 0,
                  ),
                  const Divider(height: 1),
                  _DiagnosticTile(
                    icon: Icons.history,
                    label: 'Last sync',
                    value: data.lastSyncAt == null
                        ? 'Never'
                        : DateFormat.yMMMd().add_jm().format(
                            data.lastSyncAt!.toLocal(),
                          ),
                    isProblem: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader('Connectivity'),
            Card(
              child: Column(
                children: [
                  _DiagnosticTile(
                    icon: Icons.wifi,
                    label: 'Network',
                    value: data.connectivity
                        .map((c) => c.name)
                        .join(', ')
                        .replaceAll('none', 'offline'),
                    isProblem: data.connectivity.contains(
                      conn_plus.ConnectivityResult.none,
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FilledButton.icon(
                          onPressed: _testing ? null : _runConnectionTest,
                          icon: _testing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.network_check),
                          label: const Text('Test server connection'),
                        ),
                        if (_connectionTest != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _connectionTest!.reachable
                                ? 'Reachable (${_connectionTest!.latencyMs}ms)'
                                : 'Unreachable: ${_connectionTest!.error ?? 'unknown error'}',
                            style: TextStyle(
                              color: _connectionTest!.reachable
                                  ? null
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _modeLabel(MonitoringMode mode) => mode.name;

  String _stepStatusLabel(StepTrackingStatus status) => switch (status) {
    StepTrackingStatus.active => 'Granted',
    StepTrackingStatus.permissionDenied => 'Denied',
    StepTrackingStatus.inactive => 'Not requested (mode off)',
  };

  String _permissionLabel(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always => 'Always',
        LocationPermission.whileInUse => 'While in use',
        LocationPermission.denied => 'Denied',
        LocationPermission.deniedForever => 'Denied forever',
        LocationPermission.unableToDetermine => 'Unknown',
      };
}

class _DiagnosticTile extends StatelessWidget {
  const _DiagnosticTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isProblem,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isProblem;

  @override
  Widget build(BuildContext context) {
    final color = isProblem ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(value, style: TextStyle(color: color)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
