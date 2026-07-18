import '../../data/local/tables/activity_samples_table.dart';

// Stationary GPS jitter routinely reads a few m/s of phantom speed once
// horizontal accuracy is this poor — not reliable enough to classify
// movement from.
const _maxAccuracyMetersForClassification = 25.0;

/// Rough activity estimate from instantaneous GPS speed (m/s) — no ML, just
/// speed-band thresholds. Good enough for an "estimate"; genuine activity
/// recognition would need the OS activity-recognition API.
///
/// [horizontalAccuracy] gates the estimate: a poor fix can't be trusted to
/// tell "walking" from "stationary jitter", so it falls back to `unknown`
/// (excluded from active-minutes, same as `still`) rather than asserting a
/// speed-based guess.
ActivityType classifySpeed(
  double? speedMetersPerSecond, {
  double? horizontalAccuracy,
}) {
  final speed = speedMetersPerSecond;
  if (speed == null) return ActivityType.unknown;
  // geolocator reports 0.0 for an accuracy that isn't available on this
  // device, not a genuinely perfect fix — treat it the same as "too poor
  // to trust" rather than letting it bypass the gate.
  if (horizontalAccuracy != null &&
      (horizontalAccuracy <= 0 ||
          horizontalAccuracy > _maxAccuracyMetersForClassification)) {
    return ActivityType.unknown;
  }
  if (speed < 0.3) return ActivityType.still;
  if (speed < 2.0) return ActivityType.walking;
  if (speed < 4.0) return ActivityType.running;
  if (speed < 8.0) return ActivityType.cycling;
  return ActivityType.vehicle;
}
