import 'package:shared_preferences/shared_preferences.dart';

/// Persistent sync state is scoped to one authenticated session. Keeping the
/// keys here lets logout/server changes clear them without depending on the
/// sync feature (and prevents cursor state leaking between accounts).
class SyncPreferences {
  static const _cursorKeyPrefix = 'sync_cursor_';
  static const _lastSyncKey = 'sync_last_sync_at';

  static const typeNames = [
    'location_point',
    'health_sample',
    'activity_sample',
    'goal',
    'place',
    'trip',
    'workout_session',
    'note',
  ];

  static Future<int> cursor(String typeName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_cursorKeyPrefix$typeName') ?? 0;
  }

  static Future<void> saveCursor(String typeName, int cursor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_cursorKeyPrefix$typeName', cursor);
  }

  static Future<DateTime?> lastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  static Future<void> saveLastSyncAt(DateTime at) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, at.toIso8601String());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final typeName in typeNames) {
      await prefs.remove('$_cursorKeyPrefix$typeName');
    }
    await prefs.remove(_lastSyncKey);
  }

  static Future<void> resetCursors() async {
    for (final typeName in typeNames) {
      await saveCursor(typeName, 0);
    }
  }
}
