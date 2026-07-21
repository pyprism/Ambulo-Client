import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../data/local/database.dart';
import '../../shared/widgets/empty_state.dart';
import '../places/places_providers.dart';
import 'trip_history_provider.dart';
import 'trip_route_points_provider.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripByIdProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip'),
        actions: tripAsync.value == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Rename',
                  onPressed: () => _rename(context, ref, tripAsync.value!),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _delete(context, ref, tripAsync.value!),
                ),
              ],
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load trip',
          message: '$e',
        ),
        data: (trip) {
          if (trip == null) {
            return const EmptyState(
              icon: Icons.route_outlined,
              title: 'This trip was deleted',
              message: 'It was removed from this device or another one.',
            );
          }
          return _TripDetailBody(trip: trip);
        },
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Trip trip) async {
    final controller = TextEditingController(text: trip.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename trip'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null) return;
    await ref.read(tripRepositoryProvider).updateTrip(trip.id, name: name);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete trip?'),
        content: const Text(
          'This removes it from your timeline and map on every device.',
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
    await ref.read(tripRepositoryProvider).deleteTrip(trip.id);
    if (context.mounted) context.pop();
  }
}

class _TripDetailBody extends ConsumerWidget {
  const _TripDetailBody({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider).value ?? const <Place>[];
    final placeNames = {for (final p in places) p.id: p.name};
    final startPlaceName = trip.startPlaceId == null
        ? null
        : placeNames[trip.startPlaceId];
    final endPlaceName = trip.endPlaceId == null
        ? null
        : placeNames[trip.endPlaceId];
    final duration = (trip.endedAt ?? DateTime.now()).difference(
      trip.startedAt,
    );
    final routePoints = ref.watch(tripRoutePointsProvider(trip.id)).value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (trip.name.isNotEmpty)
          Text(trip.name, style: Theme.of(context).textTheme.headlineSmall),
        if (trip.name.isNotEmpty) const SizedBox(height: 16),
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
                      '${DateFormat.yMMMEd().add_jm().format(trip.startedAt.toLocal())}'
                      ' – '
                      '${trip.endedAt == null ? 'ongoing' : DateFormat.jm().format(trip.endedAt!.toLocal())}',
                ),
                _DetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: '${duration.inMinutes} min',
                ),
                _DetailRow(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value:
                      '${(trip.distanceMeters / 1000).toStringAsFixed(2)} km',
                ),
                if (startPlaceName != null || endPlaceName != null)
                  _DetailRow(
                    icon: Icons.route_outlined,
                    label: 'Route',
                    value: [
                      startPlaceName ?? 'Unknown',
                      endPlaceName ?? 'Unknown',
                    ].join(' → '),
                  ),
              ],
            ),
          ),
        ),
        if (routePoints != null && routePoints.length >= 2) ...[
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 240,
              child: _TripRouteMap(points: routePoints),
            ),
          ),
        ],
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

class _TripRouteMap extends StatelessWidget {
  const _TripRouteMap({required this.points});

  final List<LocationPoint> points;

  @override
  Widget build(BuildContext context) {
    final routePoints = [
      for (final p in points) latlong.LatLng(p.latitude, p.longitude),
    ];
    final bounds = LatLngBounds.fromPoints(routePoints);

    return SelectionContainer.disabled(
      child: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(24),
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ambulo.ambulo',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: routePoints.first,
                width: 20,
                height: 20,
                child: Icon(
                  Icons.trip_origin,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Marker(
                point: routePoints.last,
                width: 24,
                height: 24,
                child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
