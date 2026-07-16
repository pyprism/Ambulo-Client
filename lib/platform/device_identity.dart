import 'package:flutter/foundation.dart';

String currentPlatformName() {
  if (kIsWeb) return 'web';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'android';
    case TargetPlatform.iOS:
      return 'ios';
    default:
      return 'other';
  }
}

String defaultDeviceName() {
  switch (currentPlatformName()) {
    case 'android':
      return 'Android device';
    case 'ios':
      return 'iOS device';
    case 'web':
      return 'Web browser';
    default:
      return 'Device';
  }
}
