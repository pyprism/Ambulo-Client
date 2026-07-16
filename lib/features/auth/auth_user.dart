class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.shareCode,
    required this.locationRetentionDays,
  });

  final int id;
  final String username;
  final String email;
  final bool isStaff;
  final String shareCode;

  /// Null = keep location history forever (server default). Otherwise the
  /// server purges points older than this many days (`tracking.tasks`).
  final int? locationRetentionDays;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as int,
    username: json['username'] as String,
    email: json['email'] as String,
    isStaff: json['is_staff'] as bool? ?? false,
    shareCode: json['share_code'] as String? ?? '',
    locationRetentionDays: json['location_retention_days'] as int?,
  );
}
