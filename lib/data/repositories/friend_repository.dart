import 'package:dio/dio.dart';

/// Mirrors server `utils.enums.FriendshipStatus`.
enum FriendshipStatus { pending, accepted, blocked }

FriendshipStatus _friendshipStatusFromWire(String value) => FriendshipStatus
    .values
    .firstWhere((s) => s.name == value, orElse: () => FriendshipStatus.pending);

/// A friend relationship as the server sees it — not a syncable/local
/// record (it spans two accounts, so it's plain server-mediated state,
/// fetched fresh rather than stored in Drift).
class Friendship {
  Friendship({
    required this.id,
    required this.requesterUsername,
    required this.addresseeUsername,
    required this.status,
    required this.requesterSharesLocation,
    required this.addresseeSharesLocation,
    required this.blockedByUsername,
    required this.createdAt,
    required this.respondedAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) => Friendship(
    id: json['id'] as String,
    requesterUsername: json['requester'] as String,
    addresseeUsername: json['addressee'] as String,
    status: _friendshipStatusFromWire(json['status'] as String),
    requesterSharesLocation: json['requester_shares_location'] as bool,
    addresseeSharesLocation: json['addressee_shares_location'] as bool,
    blockedByUsername: json['blocked_by'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    respondedAt: json['responded_at'] == null
        ? null
        : DateTime.parse(json['responded_at'] as String),
  );

  final String id;
  final String requesterUsername;
  final String addresseeUsername;
  final FriendshipStatus status;
  final bool requesterSharesLocation;
  final bool addresseeSharesLocation;
  final String? blockedByUsername;
  final DateTime createdAt;
  final DateTime? respondedAt;

  String otherUsername(String myUsername) =>
      requesterUsername == myUsername ? addresseeUsername : requesterUsername;

  bool mySharing(String myUsername) => requesterUsername == myUsername
      ? requesterSharesLocation
      : addresseeSharesLocation;

  bool isIncomingRequest(String myUsername) =>
      status == FriendshipStatus.pending && addresseeUsername == myUsername;

  bool isOutgoingRequest(String myUsername) =>
      status == FriendshipStatus.pending && requesterUsername == myUsername;
}

class FriendLocation {
  FriendLocation({
    required this.username,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  factory FriendLocation.fromJson(Map<String, dynamic> json) => FriendLocation(
    username: json['username'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    recordedAt: DateTime.parse(json['recorded_at'] as String),
  );

  final String username;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
}

/// Mirrors server `utils.enums.NotificationType`. The server has no real
/// push (APNs/FCM) wired up — `social.tasks.notify_friend_geofence_event`
/// only writes an in-app `Notification` row — so this in-app, poll-based
/// list *is* the notification feature, not a stand-in for it.
enum AppNotificationType {
  friendRequest,
  friendAccept,
  friendGeofence,
  unknown,
}

AppNotificationType _notificationTypeFromWire(String value) => switch (value) {
  'friend_request' => AppNotificationType.friendRequest,
  'friend_accept' => AppNotificationType.friendAccept,
  'friend_geofence' => AppNotificationType.friendGeofence,
  _ => AppNotificationType.unknown,
};

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    required this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: _notificationTypeFromWire(json['notification_type'] as String),
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
        createdAt: DateTime.parse(json['created_at'] as String),
        readAt: json['read_at'] == null
            ? null
            : DateTime.parse(json['read_at'] as String),
      );

  final String id;
  final AppNotificationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  String get message => switch (type) {
    AppNotificationType.friendRequest =>
      '${payload['from_username'] ?? 'Someone'} sent you a friend request',
    AppNotificationType.friendAccept =>
      '${payload['from_username'] ?? 'Someone'} accepted your friend request',
    AppNotificationType.friendGeofence =>
      '${payload['friend_username'] ?? 'A friend'} ${payload['event'] ?? 'entered'} '
          '${payload['place'] ?? 'a place'}',
    AppNotificationType.unknown => 'New notification',
  };
}

/// Friend requests, accept/revoke/block, per-direction share toggle, friends'
/// latest positions, and in-app notifications — all server-mediated and
/// poll-based (pulled on sync/foreground), never a persistent connection.
class FriendRepository {
  FriendRepository(this._dio);

  final Dio _dio;

  Future<List<Friendship>> listFriendships() async {
    final response = await _dio.get('/api/friends/');
    return _asList(
      response.data,
    ).map((e) => Friendship.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Friendship> sendRequest({String? username, String? shareCode}) async {
    final response = await _dio.post(
      '/api/friends/request/',
      data: {'username': ?username, 'share_code': ?shareCode},
    );
    return Friendship.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Friendship> accept(String id) async {
    final response = await _dio.post('/api/friends/$id/accept/');
    return Friendship.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> revoke(String id) => _dio.post('/api/friends/$id/revoke/');

  Future<Friendship> block(String id) async {
    final response = await _dio.post('/api/friends/$id/block/');
    return Friendship.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Friendship> setShare(String id, bool shareLocation) async {
    final response = await _dio.patch(
      '/api/friends/$id/share/',
      data: {'share_location': shareLocation},
    );
    return Friendship.fromJson(response.data as Map<String, dynamic>);
  }

  /// Not paginated server-side (a plain action response, unlike `list`).
  Future<List<FriendLocation>> friendLocations() async {
    final response = await _dio.get('/api/friends/locations/');
    return (response.data as List)
        .map((e) => FriendLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppNotification>> listNotifications() async {
    final response = await _dio.get('/api/notifications/');
    return _asList(
      response.data,
    ).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markNotificationRead(String id) =>
      _dio.post('/api/notifications/$id/mark_read/');

  /// `list` actions are paginated ({"results": [...]}); plain actions
  /// aren't. Handle both so callers don't need to know which.
  List<dynamic> _asList(dynamic data) {
    if (data is Map) return data['results'] as List;
    return data as List;
  }
}
