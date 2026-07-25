import 'package:flutter/foundation.dart';

/// Single choke point for "can this platform collect sensor/location data".
/// Web is view/edit/import/export only — no sensor collection.
abstract final class PlatformSupport {
  static bool get supportsSensorCollection => !kIsWeb;
  static bool get supportsBackgroundLocation => !kIsWeb;

  /// Health Connect is Android-only (HealthKit/iOS is a separate, deferred
  /// integration — see CLAUDE.md).
  static bool get supportsHealthConnect =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
