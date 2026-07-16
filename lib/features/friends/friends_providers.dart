import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/repositories/friend_repository.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.watch(dioProvider));
});

/// autoDispose: friends/notifications are poll-on-open (and poll-on-sync via
/// `ref.invalidate` below), not a persistent stream — no reason to keep
/// stale data around once nothing is watching.
final friendshipsProvider = FutureProvider.autoDispose<List<Friendship>>((ref) {
  return ref.watch(friendRepositoryProvider).listFriendships();
});

final friendLocationsProvider =
    FutureProvider.autoDispose<List<FriendLocation>>((ref) {
      return ref.watch(friendRepositoryProvider).friendLocations();
    });

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) {
    return ref.watch(friendRepositoryProvider).listNotifications();
  },
);

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  return ref
      .watch(notificationsProvider)
      .maybeWhen(
        data: (items) => items.where((n) => n.isUnread).length,
        orElse: () => 0,
      );
});
