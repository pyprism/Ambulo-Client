import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/sync_preferences.dart';
import 'package:ambulo/data/local/tables/health_samples_table.dart';
import 'package:ambulo/data/repositories/goal_repository.dart';
import 'package:ambulo/features/auth/auth_user.dart';
import 'package:ambulo/shared/format/app_date_format.dart';

void main() {
  group('SyncPreferences', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('persists cursors and a valid last sync timestamp', () async {
      final timestamp = DateTime.utc(2026, 7, 25, 10, 30);
      expect(await SyncPreferences.cursor('goal'), 0);

      await SyncPreferences.saveCursor('goal', 12);
      await SyncPreferences.saveLastSyncAt(timestamp);

      expect(await SyncPreferences.cursor('goal'), 12);
      expect(await SyncPreferences.lastSyncAt(), timestamp);
    });

    test('handles malformed timestamps and resets all stored state', () async {
      SharedPreferences.setMockInitialValues({
        'sync_cursor_goal': 12,
        'sync_cursor_note': 4,
        'sync_last_sync_at': 'not-a-date',
      });
      expect(await SyncPreferences.lastSyncAt(), isNull);

      await SyncPreferences.resetCursors();
      expect(await SyncPreferences.cursor('goal'), 0);
      expect(await SyncPreferences.cursor('note'), 0);
      await SyncPreferences.clear();

      expect(await SyncPreferences.lastSyncAt(), isNull);
      expect(await SyncPreferences.cursor('goal'), 0);
    });
  });

  group('GoalRepository', () {
    late AppDatabase db;
    late GoalRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = GoalRepository(db);
    });
    tearDown(() => db.close());

    test('creates then updates the active daily goal for a metric', () async {
      await repository.setDailyGoal(HealthMetricType.steps, 8000);
      await repository.setDailyGoal(HealthMetricType.steps, 9000);

      final goals = await db.select(db.goals).get();
      expect(goals, hasLength(1));
      expect(goals.single.targetValue, 9000);
      expect(goals.single.localRev, 2);
    });
  });

  test('AuthUser parsing handles optional profile fields', () {
    final user = AuthUser.fromJson({
      'id': 3,
      'username': 'sam',
      'email': 'sam@example.com',
      'date_of_birth': '1990-02-03',
      'biological_sex': '',
    });

    expect(user.isStaff, isFalse);
    expect(user.shareCode, isEmpty);
    expect(user.dateOfBirth, DateTime(1990, 2, 3));
    expect(user.biologicalSex, isNull);
  });

  test('AppDateFormat keeps the fixed display conventions', () {
    final value = DateTime(2026, 7, 25, 15, 45);
    expect(AppDateFormat.date(value), '25 Jul 2026');
    expect(AppDateFormat.dateWithWeekday(value), 'Sat, 25 Jul 2026');
    expect(AppDateFormat.time(value), '3:45 PM');
    expect(AppDateFormat.shortAxisDate(value), '25 Jul');
  });
}
