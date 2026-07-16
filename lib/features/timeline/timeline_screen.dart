import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/local/database.dart';
import '../../shared/widgets/empty_state.dart';
import '../places/places_providers.dart';
import 'trip_history_provider.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripHistoryProvider);
    final places = ref.watch(placesProvider).value ?? const <Place>[];
    final placeNames = {for (final p in places) p.id: p.name};

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load timeline',
          message: '$e',
        ),
        data: (allTrips) {
          if (allTrips.isEmpty) {
            return const EmptyState(
              icon: Icons.timeline_outlined,
              title: 'No timeline entries',
              message:
                  'Trips group your location history once Significant or '
                  'Move mode is tracking.',
            );
          }

          final byDay = <DateTime, List<Trip>>{};
          for (final trip in allTrips) {
            final local = trip.startedAt.toLocal();
            final day = DateTime(local.year, local.month, local.day);
            byDay.putIfAbsent(day, () => []).add(trip);
          }
          final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final dayTrips = byDay[day]!;
              final placesToday = {
                for (final trip in dayTrips) ...[
                  if (trip.startPlaceId != null)
                    placeNames[trip.startPlaceId] ?? 'Unknown place',
                  if (trip.endPlaceId != null)
                    placeNames[trip.endPlaceId] ?? 'Unknown place',
                ],
              };

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMEd().format(day),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (placesToday.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final name in placesToday)
                            Chip(
                              label: Text(name),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          for (final trip in dayTrips) ...[
                            _TripTile(
                              trip: trip,
                              startPlaceName: trip.startPlaceId == null
                                  ? null
                                  : placeNames[trip.startPlaceId],
                              endPlaceName: trip.endPlaceId == null
                                  ? null
                                  : placeNames[trip.endPlaceId],
                            ),
                            if (trip != dayTrips.last) const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({
    required this.trip,
    required this.startPlaceName,
    required this.endPlaceName,
  });

  final Trip trip;
  final String? startPlaceName;
  final String? endPlaceName;

  @override
  Widget build(BuildContext context) {
    final duration = (trip.endedAt ?? DateTime.now()).difference(
      trip.startedAt,
    );
    final timeRange =
        '${DateFormat.jm().format(trip.startedAt.toLocal())} – '
        '${trip.endedAt == null ? 'ongoing' : DateFormat.jm().format(trip.endedAt!.toLocal())}';
    final route = [
      if (startPlaceName != null) startPlaceName,
      if (endPlaceName != null) endPlaceName,
    ].join(' → ');

    return ListTile(
      leading: Icon(
        Icons.route_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(trip.name.isEmpty ? timeRange : trip.name),
      subtitle: Text(route.isEmpty ? timeRange : '$timeRange · $route'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${(trip.distanceMeters / 1000).toStringAsFixed(2)} km'),
          Text(
            '${duration.inMinutes} min',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
