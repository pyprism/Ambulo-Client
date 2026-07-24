import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Single choke point for local (device) notifications — currently just the
/// Move-mode battery-usage reminder, but kept as its own service so future
/// notification needs don't each reinvent plugin init.
///
/// Uses `zonedSchedule` (not a Dart `Timer`) so the reminder still fires
/// hours later even if the app process gets suspended/killed in the
/// background between location callbacks — an in-process timer would pause
/// or never fire in that scenario, exactly when the reminder matters most.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  static const _moveModeChannelId = 'move_mode_reminder';
  static const _moveModeChannelName = 'Move mode reminders';
  static const _moveModeNotificationId = 1001;
  static const moveModeReminderDelay = Duration(hours: 2);

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    // Only the elapsed-delay math matters here (fire N hours from "now"),
    // not calendar wall-clock alignment, so a fixed reference location is
    // fine — Duration addition is real-time regardless of location chosen.
    tz.setLocalLocation(tz.UTC);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );
    _initialized = true;
  }

  /// Requests notification permission. Call this when the user picks Move
  /// mode (foreground, right after their tap) — by the time a scheduled
  /// reminder is due the app may be backgrounded, when the OS can't show a
  /// permission prompt.
  Future<void> requestPermission() async {
    await _ensureInitialized();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedules the "Move mode still on" reminder for [moveModeReminderDelay]
  /// from now — Move runs a continuous high-accuracy GPS stream plus a
  /// foreground service, both meaningfully more battery-hungry than the
  /// other three modes.
  Future<void> scheduleMoveModeReminder() async {
    await _ensureInitialized();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _moveModeChannelId,
        _moveModeChannelName,
        channelDescription:
            'Reminds you when Move mode has been on for a while — it uses significant battery.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id: _moveModeNotificationId,
      title: 'Move mode still on',
      body:
          'Move mode has been tracking for ${moveModeReminderDelay.inHours} hours '
          '— this uses significant battery.',
      scheduledDate: tz.TZDateTime.now(tz.local).add(moveModeReminderDelay),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancels a pending/shown reminder — called the moment Move mode is left
  /// (mode switch or pause) so a stale reminder doesn't fire later.
  Future<void> cancelMoveModeReminder() async {
    // No-op if a reminder was never scheduled — avoids touching the native
    // plugin before it's been initialized (e.g. every non-Move mode apply).
    if (!_initialized) return;
    await _plugin.cancel(id: _moveModeNotificationId);
  }
}
