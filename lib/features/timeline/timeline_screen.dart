import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/local/database.dart';
import '../../shared/format/app_date_format.dart';
import '../../shared/widgets/date_granularity_filter.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/trip_tile.dart';
import '../places/places_providers.dart';
import 'trip_history_provider.dart';

class _TimelineDateFilterController extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void set(DateTimeRange? range) => state = range;
}

final timelineDateFilterProvider =
    NotifierProvider<_TimelineDateFilterController, DateTimeRange?>(
      _TimelineDateFilterController.new,
    );

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timelineDateFilterProvider);
    final trips = ref.watch(tripHistoryProvider(filter));
    final places = ref.watch(placesProvider).value ?? const <Place>[];
    final placeNames = {for (final p in places) p.id: p.name};

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DateGranularityFilter(
              onChanged: (range) =>
                  ref.read(timelineDateFilterProvider.notifier).set(range),
            ),
          ),
          Expanded(
            child: trips.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load timeline',
                message: '$e',
              ),
              data: (allTrips) {
                if (allTrips.isEmpty) {
                  return EmptyState(
                    icon: Icons.timeline_outlined,
                    title: filter == null
                        ? 'No timeline entries'
                        : 'No trips in this range',
                    message: filter == null
                        ? 'Trips group your location history once '
                              'Significant or Move mode is tracking.'
                        : 'Try a different day, month, or year — or clear '
                              'the filter.',
                  );
                }
                return _TripList(allTrips: allTrips, placeNames: placeNames);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  const _TripList({required this.allTrips, required this.placeNames});

  final List<Trip> allTrips;
  final Map<String, String> placeNames;

  @override
  Widget build(BuildContext context) {
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
                AppDateFormat.dateWithWeekday(day),
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
                      TripTile(
                        trip: trip,
                        startPlaceName: trip.startPlaceId == null
                            ? null
                            : placeNames[trip.startPlaceId],
                        endPlaceName: trip.endPlaceId == null
                            ? null
                            : placeNames[trip.endPlaceId],
                        onTap: () => context.push('/trips/${trip.id}'),
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
  }
}
