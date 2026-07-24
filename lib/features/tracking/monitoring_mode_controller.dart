import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/tables/location_points_table.dart';
import '../../platform/notifications/notification_service.dart';

const _prefsKey = 'monitoring_mode';

/// The four monitoring modes. Quit is the default — no tracking, all
/// sensors off, until the user explicitly picks otherwise.
class MonitoringModeController extends Notifier<MonitoringMode> {
  final _readyCompleter = Completer<void>();

  /// Resolves once the persisted mode (if any) has been loaded. Callers
  /// that apply the mode to a real sensor/service — where reading the
  /// synchronous default (`quit`) even briefly would be wrong — must await
  /// this before their first apply, not just react to the eventual state
  /// change (see `location_tracking_provider.dart`).
  Future<void> get ready => _readyCompleter.future;

  @override
  MonitoringMode build() {
    _restore();
    return MonitoringMode.quit;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      state = MonitoringMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => MonitoringMode.quit,
      );
    }
    _readyCompleter.complete();
  }

  Future<void> setMode(MonitoringMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
    if (mode == MonitoringMode.move) {
      // Ask here, not when the reminder is actually scheduled — this call
      // always comes from a foreground user tap, whereas the schedule is
      // set from `LocationTrackingService` which may run well after the
      // fact (restore on app start) or right before the app backgrounds.
      // A permission prompt hours later, while backgrounded, can't show.
      //
      // Best-effort: a missing notification plugin channel (e.g. under
      // test, or an unsupported platform) must never block picking Move.
      try {
        await NotificationService.instance.requestPermission();
      } catch (_) {}
    }
  }
}

final monitoringModeProvider =
    NotifierProvider<MonitoringModeController, MonitoringMode>(
      MonitoringModeController.new,
    );
