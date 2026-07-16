import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sync_repository.dart';
import 'sync_controller.dart';

class ConflictsScreen extends ConsumerStatefulWidget {
  const ConflictsScreen({super.key});

  @override
  ConsumerState<ConflictsScreen> createState() => _ConflictsScreenState();
}

class _ConflictsScreenState extends ConsumerState<ConflictsScreen> {
  late Future<List<ConflictSummary>> _conflicts;
  final _resolving = <String>{};
  final _resolvingAllTypes = <String>{};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _conflicts = ref.read(syncRepositoryProvider).allConflicts();
  }

  Future<void> _keepMine(ConflictSummary conflict) async {
    setState(() => _resolving.add(conflict.id));
    final error = await ref
        .read(syncControllerProvider.notifier)
        .resolveKeepMine(conflict.typeName, conflict.id);
    if (!mounted) return;
    setState(() {
      _resolving.remove(conflict.id);
      _reload();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Kept your version')));
  }

  Future<void> _takeTheirsAll(String typeName) async {
    setState(() => _resolvingAllTypes.add(typeName));
    final error = await ref
        .read(syncControllerProvider.notifier)
        .resolveAllTakeTheirs(typeName);
    if (!mounted) return;
    setState(() {
      _resolvingAllTypes.remove(typeName);
      _reload();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Discarded local changes, re-synced from server',
        ),
      ),
    );
  }

  String _typeLabel(String typeName) => switch (typeName) {
    'location_point' => 'Location',
    'health_sample' => 'Health',
    'activity_sample' => 'Activity',
    'goal' => 'Goal',
    _ => typeName,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync conflicts')),
      body: FutureBuilder<List<ConflictSummary>>(
        future: _conflicts,
        builder: (context, snapshot) {
          final conflicts = snapshot.data;
          if (conflicts == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (conflicts.isEmpty) {
            return const Center(child: Text('No conflicts to resolve'));
          }

          final byType = <String, List<ConflictSummary>>{};
          for (final c in conflicts) {
            byType.putIfAbsent(c.typeName, () => []).add(c);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'These records changed on the server since you last synced '
                'them. Keep your version to overwrite the server, or discard '
                'your local changes and re-sync everything from the server.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              for (final entry in byType.entries) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _typeLabel(entry.key),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: _resolvingAllTypes.contains(entry.key)
                          ? null
                          : () => _takeTheirsAll(entry.key),
                      child: _resolvingAllTypes.contains(entry.key)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Discard all mine'),
                    ),
                  ],
                ),
                Card(
                  child: Column(
                    children: [
                      for (final conflict in entry.value) ...[
                        ListTile(
                          title: Text(conflict.title),
                          subtitle: Text(conflict.subtitle),
                          trailing: FilledButton(
                            onPressed: _resolving.contains(conflict.id)
                                ? null
                                : () => _keepMine(conflict),
                            child: _resolving.contains(conflict.id)
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Keep mine'),
                          ),
                        ),
                        if (conflict != entry.value.last)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
