import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/server/server_config_controller.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/tables/location_points_table.dart';
import '../../platform/platform_support.dart';
import '../../platform/fitness/step_tracking_provider.dart';
import '../../platform/fitness/step_tracking_service.dart';
import '../../platform/location/location_tracking_provider.dart';
import '../../platform/location/location_tracking_service.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_user.dart';
import '../sync/sync_controller.dart';
import '../tracking/monitoring_mode_controller.dart';
import '../tracking/tracking_pause_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final monitoringMode = ref.watch(monitoringModeProvider);
    final isPaused = ref.watch(trackingPausedProvider);
    final trackingStatus = ref.watch(locationTrackingStatusProvider);
    final stepStatus = ref.watch(stepTrackingStatusProvider);
    final authUser = ref.watch(authControllerProvider).value;
    final serverAddress = ref.watch(serverConfigProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Account & server'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: Text(serverAddress ?? 'No server (local-only mode)'),
                  subtitle: const Text('Server address'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/server-setup'),
                ),
                const Divider(height: 1),
                if (authUser != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(authUser.username),
                    subtitle: Text(authUser.email),
                    trailing: TextButton(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                      child: const Text('Sign out'),
                    ),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Not signed in'),
                    subtitle: const Text('Sign in to sync across devices'),
                    trailing: FilledButton(
                      onPressed: serverAddress == null
                          ? null
                          : () => context.push('/login'),
                      child: const Text('Sign in'),
                    ),
                  ),
              ],
            ),
          ),
          if (authUser != null) ...[
            const SizedBox(height: 24),
            _SectionHeader('Friends'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Friends & sharing'),
                subtitle: const Text(
                  'Friend requests, location sharing, notifications',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/friends'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader('Data'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.import_export_outlined),
              title: const Text('Import & export'),
              subtitle: const Text('GPX, GeoJSON, CSV, JSON, OwnTracks'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/import-export'),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Sync'),
          const Card(child: _SyncStatusTile()),
          // Web is view/edit/import/export only — no sensor collection, so
          // monitoring mode is a mobile-only concept.
          if (PlatformSupport.supportsSensorCollection) ...[
            const SizedBox(height: 24),
            _SectionHeader('Monitoring mode'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final mode in MonitoringMode.values)
                          ChoiceChip(
                            label: Text(_modeLabel(mode)),
                            selected: monitoringMode == mode,
                            onSelected: (_) => ref
                                .read(monitoringModeProvider.notifier)
                                .setMode(mode),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _modeDescription(monitoringMode),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    if (!isPaused &&
                        monitoringMode != MonitoringMode.quit &&
                        monitoringMode != MonitoringMode.manual &&
                        trackingStatus != LocationTrackingStatus.active &&
                        trackingStatus != LocationTrackingStatus.inactive) ...[
                      const SizedBox(height: 12),
                      _TrackingProblemBanner(status: trackingStatus),
                    ],
                    if (!isPaused &&
                        stepStatus == StepTrackingStatus.permissionDenied) ...[
                      const SizedBox(height: 12),
                      const _StepTrackingProblemBanner(),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Steps count continuously in the background '
                      'regardless of mode — the step-counter sensor is '
                      'low-power, unlike GPS.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Pause tracking (incognito)'),
                      subtitle: const Text(
                        'Temporarily stop all collection (location and '
                        'steps) without losing your mode setting',
                      ),
                      value: isPaused,
                      onChanged: (value) => ref
                          .read(trackingPausedProvider.notifier)
                          .setPaused(value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader('Battery & background'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Move mode needs the OS to keep tracking your location '
                      'in the background. If points stop appearing while the '
                      'app isn\'t in the foreground, disable battery '
                      'optimization for Ambulo (Android: Settings → Apps → '
                      'Ambulo → Battery → Unrestricted; iOS: check Background '
                      'App Refresh and Low Power Mode).',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Geolocator.openAppSettings(),
                      icon: const Icon(Icons.app_settings_alt_outlined),
                      label: const Text('Open app settings'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader('Privacy & data'),
          Card(
            child: Column(
              children: [
                if (authUser != null) _RetentionTile(authUser: authUser),
                if (authUser != null) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('Diagnostics'),
                  subtitle: const Text(
                    'Sensor/permission/sync status, connectivity test',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/diagnostics'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text('Delete all local data'),
                  subtitle: const Text(
                    'Clears location, fitness, places, and trips stored on '
                    'this device only',
                  ),
                  onTap: () => _confirmWipeLocalData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(MonitoringMode mode) => switch (mode) {
    MonitoringMode.quit => 'Quit',
    MonitoringMode.manual => 'Manual',
    MonitoringMode.significant => 'Significant',
    MonitoringMode.move => 'Move',
  };

  String _modeDescription(MonitoringMode mode) => switch (mode) {
    MonitoringMode.quit =>
      'No location tracking. Local data stays viewable and manual sync '
          'still works. Steps keep counting regardless of mode.',
    MonitoringMode.manual =>
      'Location collected only when you explicitly tap to record. Steps '
          'keep counting regardless of mode.',
    MonitoringMode.significant =>
      'Coarse, low-power tracking using OS significant-change detection.',
    MonitoringMode.move =>
      'Precise tracking with a visible foreground indicator. Uses more battery.',
  };
}

Future<void> _confirmWipeLocalData(BuildContext context, WidgetRef ref) async {
  final signedIn = ref.read(authControllerProvider).value != null;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete all local data?'),
      content: Text(
        signedIn
            ? 'This clears location history, fitness data, places, and '
                  'trips stored on this device. Nothing is deleted from your '
                  'server — the next "Sync now" re-downloads everything, so '
                  'this is really "start this device over," not a permanent '
                  'delete.'
            : 'This permanently deletes location history, fitness data, '
                  'places, and trips stored on this device. You\'re not '
                  'signed in to a server, so this cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete everything'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(appDatabaseProvider).wipeAllLocalData();
  // Without this, the next sync would only pull changes since the old
  // cursor — everything already synced away before the wipe would never
  // come back even though it still exists server-side.
  await ref.read(syncRepositoryProvider).resetAllCursorsForRewipe();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          signedIn
              ? 'Local data deleted — "Sync now" will bring it back from the server'
              : 'Local data deleted',
        ),
      ),
    );
  }
}

class _RetentionTile extends ConsumerStatefulWidget {
  const _RetentionTile({required this.authUser});

  final AuthUser authUser;

  @override
  ConsumerState<_RetentionTile> createState() => _RetentionTileState();
}

class _RetentionTileState extends ConsumerState<_RetentionTile> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final days = widget.authUser.locationRetentionDays;
    return ListTile(
      leading: const Icon(Icons.auto_delete_outlined),
      title: const Text('Location retention'),
      subtitle: Text(
        days == null
            ? 'Keep location history forever'
            : 'Server deletes points older than $days days',
      ),
      trailing: _saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : PopupMenuButton<int?>(
              icon: const Icon(Icons.edit_outlined),
              onSelected: (value) async {
                setState(() => _saving = true);
                await ref
                    .read(authControllerProvider.notifier)
                    .setLocationRetentionDays(value);
                if (mounted) setState(() => _saving = false);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: null, child: Text('Forever')),
                PopupMenuItem(value: 30, child: Text('30 days')),
                PopupMenuItem(value: 90, child: Text('90 days')),
                PopupMenuItem(value: 365, child: Text('1 year')),
              ],
            ),
    );
  }
}

class _TrackingProblemBanner extends StatelessWidget {
  const _TrackingProblemBanner({required this.status});

  final LocationTrackingStatus status;

  @override
  Widget build(BuildContext context) {
    final (message, action) = switch (status) {
      LocationTrackingStatus.locationServiceDisabled => (
        'Location services are off, so this mode isn\'t actually tracking.',
        ('Turn on location', Geolocator.openLocationSettings),
      ),
      LocationTrackingStatus.permissionDenied => (
        'Location permission was denied, so this mode isn\'t actually '
            'tracking.',
        ('Grant permission', Geolocator.openAppSettings),
      ),
      LocationTrackingStatus.backgroundPermissionNeeded => (
        'Move mode needs "Allow all the time" location access to track in '
            'the background — "While using the app" isn\'t enough.',
        ('Open app settings', Geolocator.openAppSettings),
      ),
      _ => (null, null),
    };
    if (message == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => action.$2(),
                    child: Text(action.$1),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTrackingProblemBanner extends StatelessWidget {
  const _StepTrackingProblemBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step-counting permission was denied, so steps aren\'t '
                  'being recorded.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: const Text('Grant permission'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusTile extends ConsumerWidget {
  const _SyncStatusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    final isSyncing = syncState.isLoading;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          syncState.when(
            data: (counts) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  counts.lastSyncAt == null
                      ? 'Never synced'
                      : 'Last synced ${DateFormat.yMMMd().add_jm().format(counts.lastSyncAt!.toLocal())}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _CountBadge(label: 'Pending', count: counts.pending),
                    _CountBadge(
                      label: 'Failed',
                      count: counts.failed,
                      isError: counts.failed > 0,
                    ),
                    _CountBadge(
                      label: 'Conflicts',
                      count: counts.conflicts,
                      isError: counts.conflicts > 0,
                    ),
                  ],
                ),
                if (counts.conflicts > 0) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/sync-conflicts'),
                    child: const Text('Review conflicts'),
                  ),
                ],
              ],
            ),
            loading: () => const Text('Syncing…'),
            error: (e, _) => Text('Sync status unavailable: $e'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSyncing
                  ? null
                  : () async {
                      final error = await ref
                          .read(syncControllerProvider.notifier)
                          .syncNow();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error ?? 'Sync complete')),
                      );
                    },
              icon: isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: const Text('Sync now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.label,
    required this.count,
    this.isError = false,
  });

  final String label;
  final int count;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.outline;
    return Text('$label: $count', style: TextStyle(color: color));
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
