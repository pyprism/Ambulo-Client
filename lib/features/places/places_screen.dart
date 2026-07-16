import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/local/database.dart';
import '../../data/local/tables/places_table.dart';
import '../../platform/platform_support.dart';
import '../../shared/widgets/empty_state.dart';
import 'places_providers.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Places')),
      body: places.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load places',
          message: '$e',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.place_outlined,
              title: 'No places yet',
              message:
                  'Add home, work, or any place you want enter/leave events '
                  'for.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _PlaceTile(place: items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlaceEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add place'),
      ),
    );
  }
}

class _PlaceTile extends ConsumerWidget {
  const _PlaceTile({required this.place});

  final Place place;

  IconData get _icon => switch (place.category) {
    PlaceCategory.home => Icons.home_outlined,
    PlaceCategory.work => Icons.work_outline,
    PlaceCategory.gym => Icons.fitness_center_outlined,
    PlaceCategory.travel => Icons.flight_outlined,
    PlaceCategory.custom => Icons.place_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(_icon, color: Theme.of(context).colorScheme.primary),
      title: Text(place.name),
      subtitle: Text(
        '${place.radiusMeters.round()}m radius'
        '${place.currentlyInside ? ' · currently here' : ''}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'edit') {
            _showPlaceEditor(context, ref, existing: place);
          } else if (value == 'delete') {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Delete "${place.name}"?'),
                content: const Text(
                  'This removes the place and stops enter/leave tracking for it.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;
            try {
              await ref.read(placeRepositoryProvider).deletePlace(place.id);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not delete place: $e')),
                );
              }
            }
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

Future<void> _showPlaceEditor(
  BuildContext context,
  WidgetRef ref, {
  Place? existing,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _PlaceEditorDialog(existing: existing),
  );
}

class _PlaceEditorDialog extends ConsumerStatefulWidget {
  const _PlaceEditorDialog({this.existing});

  final Place? existing;

  @override
  ConsumerState<_PlaceEditorDialog> createState() => _PlaceEditorDialogState();
}

class _PlaceEditorDialogState extends ConsumerState<_PlaceEditorDialog> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _radius = TextEditingController(
    text: '${widget.existing?.radiusMeters.round() ?? 100}',
  );
  late final _latitude = TextEditingController(
    text: widget.existing?.latitude.toString(),
  );
  late final _longitude = TextEditingController(
    text: widget.existing?.longitude.toString(),
  );
  late PlaceCategory _category =
      widget.existing?.category ?? PlaceCategory.custom;
  bool _locating = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _latitude.text = position.latitude.toString();
        _longitude.text = position.longitude.toString();
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  bool _saving = false;

  Future<void> _save() async {
    final latitude = double.tryParse(_latitude.text);
    final longitude = double.tryParse(_longitude.text);
    if (_name.text.trim().isEmpty || latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and location are required')),
      );
      return;
    }
    final radius = double.tryParse(_radius.text) ?? 100;
    setState(() => _saving = true);
    try {
      final repo = ref.read(placeRepositoryProvider);
      if (widget.existing == null) {
        await repo.addPlace(
          name: _name.text.trim(),
          category: _category,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radius,
          address: _address.text.trim(),
        );
      } else {
        await repo.updatePlace(
          widget.existing!.id,
          name: _name.text.trim(),
          category: _category,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radius,
          address: _address.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save place: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add place' : 'Edit place'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlaceCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in PlaceCategory.values)
                  DropdownMenuItem(value: category, child: Text(category.name)),
              ],
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radius,
              decoration: const InputDecoration(labelText: 'Radius (meters)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitude,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _longitude,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
              ],
            ),
            if (PlatformSupport.supportsSensorCollection) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _locating ? null : _useCurrentLocation,
                icon: _locating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Use current location'),
              ),
            ],
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
