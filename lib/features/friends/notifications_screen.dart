import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/friend_repository.dart';
import '../../shared/widgets/empty_state.dart';
import 'friends_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: notifications.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => RefreshableEmptyState(
            icon: Icons.error_outline,
            title: 'Could not load notifications',
            message: '$e',
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    child: const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'No notifications',
                      message:
                          'Friend requests and friend geofence events show up here.',
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _NotificationTile(notification: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  IconData get _icon => switch (notification.type) {
    AppNotificationType.friendRequest => Icons.person_add_alt_outlined,
    AppNotificationType.friendGeofence => Icons.place_outlined,
    AppNotificationType.unknown => Icons.notifications_none,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        _icon,
        color: notification.isUnread
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(notification.message),
      subtitle: Text(
        DateFormat.yMMMd().add_jm().format(notification.createdAt.toLocal()),
      ),
      trailing: notification.isUnread
          ? const Icon(Icons.circle, size: 10)
          : null,
      onTap: notification.isUnread
          ? () async {
              try {
                await ref
                    .read(friendRepositoryProvider)
                    .markNotificationRead(notification.id);
                ref.invalidate(notificationsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not mark as read: $e')),
                  );
                }
              }
            }
          : null,
    );
  }
}
