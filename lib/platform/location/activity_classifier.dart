import '../../data/local/tables/activity_samples_table.dart';

/// Rough activity estimate from instantaneous GPS speed (m/s) — no ML, just
/// SPEC-sanctioned speed-band thresholds. Good enough for an "estimate";
/// genuine activity recognition would need the OS activity-recognition API.
ActivityType classifySpeed(double? speedMetersPerSecond) {
  final speed = speedMetersPerSecond;
  if (speed == null) return ActivityType.unknown;
  if (speed < 0.3) return ActivityType.still;
  if (speed < 2.0) return ActivityType.walking;
  if (speed < 4.0) return ActivityType.running;
  if (speed < 8.0) return ActivityType.cycling;
  return ActivityType.vehicle;
}
