import 'package:flutter/material.dart';

import '../../data/local/database.dart';
import '../format/app_date_format.dart';

/// A single trip row — shared between the Timeline list and the Map's trip
/// panel so both navigate to the same detail/edit/delete screen the same
/// way.
class TripTile extends StatelessWidget {
  const TripTile({
    super.key,
    required this.trip,
    required this.startPlaceName,
    required this.endPlaceName,
    this.onTap,
  });

  final Trip trip;
  final String? startPlaceName;
  final String? endPlaceName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final duration = (trip.endedAt ?? DateTime.now()).difference(
      trip.startedAt,
    );
    final timeRange =
        '${AppDateFormat.time(trip.startedAt.toLocal())} – '
        '${trip.endedAt == null ? 'ongoing' : AppDateFormat.time(trip.endedAt!.toLocal())}';
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
      onTap: onTap,
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
