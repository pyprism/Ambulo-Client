import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../data/local/database.dart';
import '../../platform/location/location_tracking_provider.dart';
import '../../platform/platform_support.dart';
import '../../shared/widgets/date_granularity_filter.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/trip_tile.dart';
import '../auth/auth_controller.dart';
import '../friends/friends_providers.dart';
import '../places/places_providers.dart';
import '../timeline/trip_history_provider.dart';
import 'location_history_provider.dart';

class _MapDateFilterController extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void set(DateTimeRange? range) => state = range;
}

final mapDateFilterProvider =
    NotifierProvider<_MapDateFilterController, DateTimeRange?>(
      _MapDateFilterController.new,
    );

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  bool _recording = false;

  Future<void> _recordNow() async {
    setState(() => _recording = true);
    final ok = await ref
        .read(locationTrackingServiceProvider)
        .recordManualPoint();
    if (!mounted) return;
    setState(() => _recording = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Location recorded'
              : 'Could not get a location — check permissions and that location services are on.',
        ),
      ),
    );
  }

  void _showTrips(DateTimeRange? filter) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TripsSheet(filter: filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(mapDateFilterProvider);
    final history = ref.watch(locationHistoryProvider(filter));

    final places = ref.watch(placesProvider).value ?? const [];
    final isSignedIn = ref.watch(authControllerProvider).value != null;
    final friendLocations = isSignedIn
        ? ref.watch(friendLocationsProvider).value ?? const []
        : const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.route_outlined),
            tooltip: 'Trips',
            onPressed: () => _showTrips(filter),
          ),
          IconButton(
            icon: const Icon(Icons.place_outlined),
            tooltip: 'Places',
            onPressed: () => context.push('/places'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DateGranularityFilter(
              onChanged: (range) =>
                  ref.read(mapDateFilterProvider.notifier).set(range),
            ),
          ),
          Expanded(
            child: history.when(
              data: (points) {
                // Show the map (with places/friends overlays) as soon as
                // there's *anything* to put on it — not just once this
                // device has its own history. A brand-new device with a
                // friend already sharing, or one that's only ever added
                // places, shouldn't see an empty state.
                if (points.isEmpty &&
                    places.isEmpty &&
                    friendLocations.isEmpty) {
                  return const EmptyState(
                    icon: Icons.map_outlined,
                    title: 'Nothing to show yet',
                    message:
                        'Your position history, saved places, and friends\' '
                        'shared locations will show up here.',
                  );
                }

                final center = points.isNotEmpty
                    ? latlong.LatLng(
                        points.first.latitude,
                        points.first.longitude,
                      )
                    : friendLocations.isNotEmpty
                    ? latlong.LatLng(
                        friendLocations.first.latitude,
                        friendLocations.first.longitude,
                      )
                    : latlong.LatLng(
                        places.first.latitude,
                        places.first.longitude,
                      );
                final routePoints = points
                    .map((p) => latlong.LatLng(p.latitude, p.longitude))
                    .toList()
                    .reversed
                    .toList();

                // The app-wide SelectionArea (for copyable text) otherwise
                // fights flutter_map's own drag-to-pan/pinch-to-zoom
                // gestures.
                return SelectionContainer.disabled(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: center, initialZoom: 14),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ambulo.ambulo',
                      ),
                      if (routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      CircleLayer(
                        circles: [
                          for (final place in places)
                            CircleMarker(
                              point: latlong.LatLng(
                                place.latitude,
                                place.longitude,
                              ),
                              radius: place.radiusMeters,
                              useRadiusInMeter: true,
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiary.withValues(alpha: 0.15),
                              borderColor: Theme.of(
                                context,
                              ).colorScheme.tertiary,
                              borderStrokeWidth: 1,
                            ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          for (final place in places)
                            Marker(
                              point: latlong.LatLng(
                                place.latitude,
                                place.longitude,
                              ),
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.place,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 28,
                              ),
                            ),
                          for (final friend in friendLocations)
                            Marker(
                              point: latlong.LatLng(
                                friend.latitude,
                                friend.longitude,
                              ),
                              width: 32,
                              height: 44,
                              child: _FriendMarker(username: friend.username),
                            ),
                          if (points.isNotEmpty)
                            Marker(
                              point: center,
                              width: 32,
                              height: 32,
                              child: Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 32,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load location history',
                message: '$e',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: PlatformSupport.supportsSensorCollection
          ? FloatingActionButton.extended(
              onPressed: _recording ? null : _recordNow,
              icon: _recording
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Record now'),
            )
          : null,
    );
  }
}

class _FriendMarker extends StatelessWidget {
  const _FriendMarker({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            username,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.person_pin_circle, color: color, size: 28),
      ],
    );
  }
}

class _TripsSheet extends ConsumerWidget {
  const _TripsSheet({required this.filter});

  final DateTimeRange? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripHistoryProvider(filter));
    final places = ref.watch(placesProvider).value ?? const <Place>[];
    final placeNames = {for (final p in places) p.id: p.name};

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return trips.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load trips',
            message: '$e',
          ),
          data: (allTrips) {
            if (allTrips.isEmpty) {
              return EmptyState(
                icon: Icons.route_outlined,
                title: filter == null
                    ? 'No trips yet'
                    : 'No trips in this range',
                message: filter == null
                    ? 'Trips group your location history once Significant '
                          'or Move mode is tracking.'
                    : 'Try a different day, month, or year.',
              );
            }
            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: allTrips.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final trip = allTrips[index];
                return TripTile(
                  trip: trip,
                  startPlaceName: trip.startPlaceId == null
                      ? null
                      : placeNames[trip.startPlaceId],
                  endPlaceName: trip.endPlaceId == null
                      ? null
                      : placeNames[trip.endPlaceId],
                  onTap: () {
                    // Resolve the router before popping — pushing on a
                    // context whose element is mid-teardown from the pop
                    // is exactly the kind of thing that "usually" works.
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/trips/${trip.id}');
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
