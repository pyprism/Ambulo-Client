class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.shareCode,
    required this.locationRetentionDays,
    required this.dateOfBirth,
    required this.biologicalSex,
  });

  final int id;
  final String username;
  final String email;
  final bool isStaff;
  final String shareCode;

  /// Null = keep location history forever (server default). Otherwise the
  /// server purges points older than this many days (`tracking.tasks`).
  final int? locationRetentionDays;

  /// Personal-profile fields used client-side for the BMR calorie estimate
  /// (`FitnessStatsRepository`). Kept as raw wire types here (not the
  /// fitness feature's `BiologicalSex` enum) so this file doesn't have to
  /// depend on another feature — `UserProfileController` does the mapping.
  final DateTime? dateOfBirth;
  final String? biologicalSex;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as int,
    username: json['username'] as String,
    email: json['email'] as String,
    isStaff: json['is_staff'] as bool? ?? false,
    shareCode: json['share_code'] as String? ?? '',
    locationRetentionDays: json['location_retention_days'] as int?,
    dateOfBirth: (json['date_of_birth'] as String?) == null
        ? null
        : DateTime.parse(json['date_of_birth'] as String),
    biologicalSex: (json['biological_sex'] as String?)?.isEmpty ?? true
        ? null
        : json['biological_sex'] as String,
  );
}
