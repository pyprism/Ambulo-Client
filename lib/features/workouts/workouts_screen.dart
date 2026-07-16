import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/local/database.dart';
import '../../data/local/tables/activity_samples_table.dart';
import '../../shared/widgets/empty_state.dart';
import 'workout_providers.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: workouts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load workouts',
          message: '$e',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.fitness_center_outlined,
              title: 'No workouts logged yet',
              message: 'Log a run, ride, or any workout to track it here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _WorkoutTile(workout: items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWorkoutEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Log workout'),
      ),
    );
  }
}

IconData _activityIcon(ActivityType type) => switch (type) {
  ActivityType.walking => Icons.directions_walk,
  ActivityType.running => Icons.directions_run,
  ActivityType.cycling => Icons.directions_bike,
  ActivityType.vehicle => Icons.directions_car,
  ActivityType.still => Icons.pause_circle_outline,
  ActivityType.unknown => Icons.fitness_center_outlined,
};

String _activityLabel(ActivityType type) => switch (type) {
  ActivityType.walking => 'Walking',
  ActivityType.running => 'Running',
  ActivityType.cycling => 'Cycling',
  ActivityType.vehicle => 'Vehicle',
  ActivityType.still => 'Still',
  ActivityType.unknown => 'Workout',
};

class _WorkoutTile extends ConsumerWidget {
  const _WorkoutTile({required this.workout});

  final WorkoutSession workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = (workout.endedAt ?? workout.startedAt).difference(
      workout.startedAt,
    );
    final distanceKm = (workout.distanceMeters ?? 0) / 1000;

    return ListTile(
      leading: Icon(
        _activityIcon(workout.activityType),
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(_activityLabel(workout.activityType)),
      subtitle: Text(
        DateFormat.yMMMd().add_jm().format(workout.startedAt.toLocal()),
      ),
      onTap: () => _showWorkoutEditor(context, ref, existing: workout),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (duration.inMinutes > 0) Text('${duration.inMinutes} min'),
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

Future<void> _showWorkoutEditor(
  BuildContext context,
  WidgetRef ref, {
  WorkoutSession? existing,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _WorkoutEditorDialog(existing: existing),
  );
}

class _WorkoutEditorDialog extends ConsumerStatefulWidget {
  const _WorkoutEditorDialog({this.existing});

  final WorkoutSession? existing;

  @override
  ConsumerState<_WorkoutEditorDialog> createState() =>
      _WorkoutEditorDialogState();
}

class _WorkoutEditorDialogState extends ConsumerState<_WorkoutEditorDialog> {
  late ActivityType _activityType =
      widget.existing?.activityType ?? ActivityType.running;
  late DateTime _startedAt = widget.existing?.startedAt ?? DateTime.now();
  late final _distance = TextEditingController(
    text: widget.existing?.distanceMeters == null
        ? ''
        : (widget.existing!.distanceMeters! / 1000).toString(),
  );
  late final _calories = TextEditingController(
    text: widget.existing?.calories?.toString(),
  );
  late final _notes = TextEditingController(text: widget.existing?.notes);
  bool _saving = false;

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startedAt),
    );
    if (time == null) return;
    setState(
      () => _startedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(workoutSessionRepositoryProvider);
      final distanceKm = double.tryParse(_distance.text);
      final calories = double.tryParse(_calories.text);
      if (widget.existing == null) {
        await repo.addWorkout(
          activityType: _activityType,
          startedAt: _startedAt,
          distanceMeters: distanceKm == null ? null : distanceKm * 1000,
          calories: calories,
          notes: _notes.text.trim(),
        );
      } else {
        await repo.updateWorkout(
          widget.existing!.id,
          activityType: _activityType,
          startedAt: _startedAt,
          distanceMeters: distanceKm == null ? null : distanceKm * 1000,
          calories: calories,
          notes: _notes.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save workout: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _distance.dispose();
    _calories.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Log workout' : 'Edit workout'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<ActivityType>(
              initialValue: _activityType,
              decoration: const InputDecoration(labelText: 'Activity'),
              items: [
                for (final type in [
                  ActivityType.walking,
                  ActivityType.running,
                  ActivityType.cycling,
                  ActivityType.vehicle,
                  ActivityType.unknown,
                ])
                  DropdownMenuItem(
                    value: type,
                    child: Text(_activityLabel(type)),
                  ),
              ],
              onChanged: (value) => setState(() => _activityType = value!),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickStart,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(DateFormat.yMMMd().add_jm().format(_startedAt)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _distance,
              decoration: const InputDecoration(labelText: 'Distance (km)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _calories,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
