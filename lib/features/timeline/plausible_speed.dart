import '../../data/local/database.dart';

/// Filters route points down to physically plausible speed readings before
/// any max/avg speed display. GPS speed spikes (multipath, cold fixes,
/// Significant mode's `LocationAccuracy.reduced`) can be pure noise —
/// `speedAccuracy`/`horizontalAccuracy` only filter when the platform
/// actually reported them, so legacy rows (recorded before those columns
/// existed) pass through unfiltered rather than being dropped.
List<double> plausibleSpeedsMps(List<LocationPoint> points) {
  return [
    for (final p in points)
      if (p.speed != null &&
          (p.horizontalAccuracy == null || p.horizontalAccuracy! <= 50) &&
          (p.speedAccuracy == null || p.speedAccuracy! <= 2))
        p.speed!,
  ];
}
