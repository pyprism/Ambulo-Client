import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/local/database.dart';
import '../../data/local/tables/activity_samples_table.dart';
import '../../shared/widgets/empty_state.dart';
import 'activity_history_provider.dart';
import 'fitness_providers.dart';

IconData _activityIcon(ActivityType type) => switch (type) {
  ActivityType.walking => Icons.directions_walk,
  ActivityType.running => Icons.directions_run,
  ActivityType.cycling => Icons.directions_bike,
  ActivityType.vehicle => Icons.directions_car,
  ActivityType.still => Icons.pause_circle_outline,
  ActivityType.unknown => Icons.help_outline,
};

String _activityLabel(ActivityType type) => switch (type) {
  ActivityType.walking => 'Walking',
  ActivityType.running => 'Running',
  ActivityType.cycling => 'Cycling',
  ActivityType.vehicle => 'Vehicle',
  ActivityType.still => 'Still',
  ActivityType.unknown => 'Unknown',
};

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segmentAsync = ref.watch(activitySampleByIdProvider(activityId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: segmentAsync.value == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Reclassify',
                  onPressed: () =>
                      _reclassify(context, ref, segmentAsync.value!),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _delete(context, ref, segmentAsync.value!),
                ),
              ],
      ),
      body: segmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load activity',
          message: '$e',
        ),
        data: (segment) {
          if (segment == null) {
            return const EmptyState(
              icon: Icons.directions_walk_outlined,
              title: 'This activity was deleted',
              message: 'It was removed from this device or another one.',
            );
          }
          return _ActivityDetailBody(segment: segment);
        },
      ),
    );
  }

  Future<void> _reclassify(
    BuildContext context,
    WidgetRef ref,
    ActivitySample segment,
  ) async {
    final selected = await showDialog<ActivityType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Reclassify activity'),
        children: [
          for (final type in ActivityType.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(type),
              child: Row(
                children: [
                  Icon(_activityIcon(type), size: 20),
                  const SizedBox(width: 12),
                  Text(_activityLabel(type)),
                ],
              ),
            ),
        ],
      ),
    );
    if (selected == null || selected == segment.activityType) return;
    await ref
        .read(activitySampleRepositoryProvider)
        .updateActivityType(segment.id, selected);
    // statsForDay is a one-shot FutureProvider, not reactive to DB writes —
    // a reclassify changes active-minutes (still/vehicle vs
    // walking/running/cycling), so the dashboard needs a manual nudge to
    // pick it up, same as after logging a weight/height reading.
    ref.invalidate(todayStatsProvider);
    ref.invalidate(weeklyStatsProvider);
    ref.invalidate(monthlyStatsProvider);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ActivitySample segment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete activity?'),
        content: const Text(
          'This removes it from your fitness history on every device. It '
          'does not affect the raw location/step data it was detected from.',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(activitySampleRepositoryProvider)
        .deleteActivitySample(segment.id);
    ref.invalidate(todayStatsProvider);
    ref.invalidate(weeklyStatsProvider);
    ref.invalidate(monthlyStatsProvider);
    if (context.mounted) context.pop();
  }
}

class _ActivityDetailBody extends StatelessWidget {
  const _ActivityDetailBody({required this.segment});

  final ActivitySample segment;

  @override
  Widget build(BuildContext context) {
    final duration = (segment.endedAt ?? DateTime.now()).difference(
      segment.startedAt,
    );
    final distanceKm = (segment.distanceMeters ?? 0) / 1000;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(
              _activityIcon(segment.activityType),
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _activityLabel(segment.activityType),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.schedule,
                  label: 'Time',
                  value:
                      '${DateFormat.yMMMEd().add_jm().format(segment.startedAt.toLocal())}'
                      ' – '
                      '${segment.endedAt == null ? 'ongoing' : DateFormat.jm().format(segment.endedAt!.toLocal())}',
                ),
                _DetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: '${duration.inMinutes} min',
                ),
                if (distanceKm > 0)
                  _DetailRow(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '${distanceKm.toStringAsFixed(2)} km',
                  ),
                if (segment.steps != null)
                  _DetailRow(
                    icon: Icons.directions_walk,
                    label: 'Steps',
                    value: '${segment.steps}',
                  ),
                if (segment.confidence != null)
                  _DetailRow(
                    icon: Icons.insights_outlined,
                    label: 'Detection confidence',
                    value: '${(segment.confidence! * 100).round()}%',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
