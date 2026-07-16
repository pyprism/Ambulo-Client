import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/local/database.dart';
import '../../shared/widgets/empty_state.dart';
import 'activity_history_provider.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(activityHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center_outlined),
            tooltip: 'Workouts',
            onPressed: () => context.push('/workouts'),
          ),
          IconButton(
            icon: const Icon(Icons.notes_outlined),
            tooltip: 'Notes',
            onPressed: () => context.push('/notes'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Charts',
            onPressed: () => context.push('/charts'),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load activity history',
          message: '$e',
        ),
        data: (segments) {
          if (segments.isEmpty) {
            return const EmptyState(
              icon: Icons.directions_walk_outlined,
              title: 'No fitness data yet',
              message:
                  'Steps, distance, active minutes, and detected activity '
                  'segments will appear here once tracking starts.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: segments.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _ActivityTile(segment: segments[index]),
          );
        },
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.segment});

  final ActivitySample segment;

  IconData get _icon => switch (segment.activityType.name) {
    'walking' => Icons.directions_walk,
    'running' => Icons.directions_run,
    'cycling' => Icons.directions_bike,
    'vehicle' => Icons.directions_car,
    'still' => Icons.pause_circle_outline,
    _ => Icons.help_outline,
  };

  String get _label => switch (segment.activityType.name) {
    'walking' => 'Walking',
    'running' => 'Running',
    'cycling' => 'Cycling',
    'vehicle' => 'Vehicle',
    'still' => 'Still',
    _ => 'Unknown',
  };

  @override
  Widget build(BuildContext context) {
    final duration = (segment.endedAt ?? DateTime.now()).difference(
      segment.startedAt,
    );
    final distanceKm = (segment.distanceMeters ?? 0) / 1000;

    return ListTile(
      leading: Icon(_icon, color: Theme.of(context).colorScheme.primary),
      title: Text(_label),
      subtitle: Text(
        DateFormat.yMMMd().add_jm().format(segment.startedAt.toLocal()),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${duration.inMinutes} min'),
          if (distanceKm > 0)
            Text(
              '${distanceKm.toStringAsFixed(2)} km',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
