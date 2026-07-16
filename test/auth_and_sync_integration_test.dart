// Exercises the real Phase 1a stack (register, login, device registration,
// upload/download sync) against a live Ambulo server. Requires
// `./scripts/dockerless_run.sh runserver` running in ../Ambulo on
// 127.0.0.1:8000; skipped automatically if that server isn't reachable.
//
// Deliberately a plain `test()`, not `testWidgets()`: testWidgets runs under
// a fake-async zone that hangs forever on real socket I/O unless wrapped in
// tester.runAsync — calling the controllers directly through a
// ProviderContainer exercises the exact same repository/controller logic
// the UI calls, without that complication.
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ambulo/core/network/dio_client.dart';
import 'package:ambulo/core/server/server_config_controller.dart';
import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/database_provider.dart';
import 'package:ambulo/data/local/secure_token_storage.dart';
import 'package:ambulo/data/local/tables/activity_samples_table.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/places_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/features/auth/auth_controller.dart';
import 'package:ambulo/features/sync/sync_controller.dart';

const _serverUrl = 'http://127.0.0.1:8000';

class _FakeTokenStorage implements TokenStorage {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;
  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> saveAccessToken(String accessToken) async {
    _access = accessToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

Future<bool> _serverReachable() async {
  try {
    final client = HttpClient();
    // /healthz can block ~2s on its Celery ping when no worker is running
    // (not needed for this test — auth/sync don't touch Celery), so this
    // needs real headroom above that, not a tight timeout.
    final request = await client.getUrl(Uri.parse('$_serverUrl/api/healthz/'));
    final response = await request.close().timeout(const Duration(seconds: 6));
    return response.statusCode == 200 || response.statusCode == 503;
  } catch (_) {
    return false;
  }
}

void main() {
  test(
    'register, login, device registration, and sync round-trip against the real server',
    () async {
      // Force TestWidgetsFlutterBinding's lazy init (which installs its own
      // network-blocking HttpOverrides) to happen now, then clear it — so no
      // later first-touch of a platform channel silently reinstalls it
      // before the real HTTP calls below.
      TestWidgetsFlutterBinding.ensureInitialized();
      HttpOverrides.global = null;

      if (!await _serverReachable()) {
        // ignore: avoid_print
        print('Skipping: no live server at $_serverUrl');
        return;
      }

      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          appDatabaseProvider.overrideWithValue(
            AppDatabase.forTesting(NativeDatabase.memory()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(serverConfigProvider.notifier)
          .setServerAddress(_serverUrl);

      final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
      final username = 'flutter_it_$uniqueSuffix';

      final registerError = await container
          .read(authControllerProvider.notifier)
          .register(
            username: username,
            email: '$username@example.com',
            password: 'Sup3rSecretPass!',
          );
      expect(registerError, isNull, reason: 'register failed: $registerError');

      final authedUser = container.read(authControllerProvider).value;
      expect(authedUser, isNotNull);
      expect(authedUser!.username, username);

      // Seed one pending location point and run a real sync.
      final db = container.read(appDatabaseProvider);
      await db
          .into(db.locationPoints)
          .insert(
            LocationPointsCompanion.insert(
              latitude: 12.34,
              longitude: 56.78,
              recordedAt: DateTime.now().toUtc(),
              monitoringMode: MonitoringMode.significant,
              syncState: const Value(SyncState.pendingUpload),
              source: RecordSource.location,
            ),
          );

      final beforeCounts = await container
          .read(syncRepositoryProvider)
          .counts();
      expect(beforeCounts.pending, 1);

      final syncError = await container
          .read(syncControllerProvider.notifier)
          .syncNow();
      expect(syncError, isNull, reason: 'sync failed: $syncError');

      final afterCounts = container.read(syncControllerProvider).value!;
      expect(afterCounts.pending, 0);
      expect(afterCounts.failed, 0);
      expect(afterCounts.conflicts, 0);
      expect(afterCounts.lastSyncAt, isNotNull);

      final rows = await db.select(db.locationPoints).get();
      expect(rows.single.syncState, SyncState.synced);
      expect(rows.single.serverRev, isNotNull);

      // Logout should blacklist the refresh token server-side without
      // throwing, and clear local auth state.
      await container.read(authControllerProvider.notifier).logout();
      expect(container.read(authControllerProvider).value, isNull);
    },
  );

  test('conflict detection and "keep mine" resolution against the real server', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    if (!await _serverReachable()) {
      // ignore: avoid_print
      print('Skipping: no live server at $_serverUrl');
      return;
    }

    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        appDatabaseProvider.overrideWithValue(
          AppDatabase.forTesting(NativeDatabase.memory()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(serverConfigProvider.notifier)
        .setServerAddress(_serverUrl);

    final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
    final username = 'flutter_it_conflict_$uniqueSuffix';
    final registerError = await container
        .read(authControllerProvider.notifier)
        .register(
          username: username,
          email: '$username@example.com',
          password: 'Sup3rSecretPass!',
        );
    expect(registerError, isNull, reason: 'register failed: $registerError');

    final db = container.read(appDatabaseProvider);
    await db
        .into(db.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: 1,
            longitude: 1,
            recordedAt: DateTime.now().toUtc(),
            monitoringMode: MonitoringMode.significant,
            syncState: const Value(SyncState.pendingUpload),
            source: RecordSource.location,
          ),
        );
    final pointId = (await db.select(db.locationPoints).getSingle()).id;

    // Get it synced once so it has a real server_rev.
    final firstSyncError = await container
        .read(syncControllerProvider.notifier)
        .syncNow();
    expect(firstSyncError, isNull, reason: 'initial sync failed: $firstSyncError');
    final syncedRow = await (db.select(
      db.locationPoints,
    )..where((t) => t.id.equals(pointId))).getSingle();
    expect(syncedRow.syncState, SyncState.synced);
    final syncedServerRev = syncedRow.serverRev;
    expect(syncedServerRev, isNotNull);

    // Simulate a second device changing this record server-side (accepted,
    // bumps server_rev) without this client knowing — reuse the same
    // authenticated Dio client to make that write.
    final otherDeviceResponse = await container
        .read(dioProvider)
        .post(
          '/api/sync/upload/',
          data: {
            'records': {
              'location_point': [
                {
                  'id': pointId,
                  'local_rev': 1,
                  'base_server_rev': syncedServerRev,
                  'sync_state': 'synced',
                  'source': 'location',
                  'latitude': 9.0,
                  'longitude': 9.0,
                  'recorded_at': DateTime.now().toUtc().toIso8601String(),
                  'connectivity': 'wifi',
                  'monitoring_mode': 'significant',
                },
              ],
            },
          },
        );
    final otherDeviceBucket =
        (otherDeviceResponse.data as Map<String, dynamic>)['location_point']
            as Map<String, dynamic>;
    expect((otherDeviceBucket['accepted'] as List), contains(pointId));

    // Now make a conflicting local edit (still holding the stale server_rev)
    // and try to sync it — the server must reject it as a conflict.
    await (db.update(db.locationPoints)..where((t) => t.id.equals(pointId)))
        .write(
          const LocationPointsCompanion(
            latitude: Value(5.0),
            syncState: Value(SyncState.pendingUpload),
          ),
        );

    final conflictSyncError = await container
        .read(syncControllerProvider.notifier)
        .syncNow();
    expect(conflictSyncError, isNull);

    final conflicted = await container
        .read(syncRepositoryProvider)
        .allConflicts();
    expect(conflicted.map((c) => c.id), contains(pointId));

    // Resolve by keeping our version — must force-overwrite and end up synced.
    final resolveError = await container
        .read(syncControllerProvider.notifier)
        .resolveKeepMine('location_point', pointId);
    expect(resolveError, isNull, reason: 'resolveKeepMine failed: $resolveError');

    final resolvedRow = await (db.select(
      db.locationPoints,
    )..where((t) => t.id.equals(pointId))).getSingle();
    expect(resolvedRow.syncState, SyncState.synced);
    expect(resolvedRow.latitude, 5.0);
  });

  test(
    'registration validation errors surface the real backend detail, not just the generic summary',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      HttpOverrides.global = null;

      if (!await _serverReachable()) {
        // ignore: avoid_print
        print('Skipping: no live server at $_serverUrl');
        return;
      }

      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          appDatabaseProvider.overrideWithValue(
            AppDatabase.forTesting(NativeDatabase.memory()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(serverConfigProvider.notifier)
          .setServerAddress(_serverUrl);

      final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
      final username = 'flutter_it_weakpw_$uniqueSuffix';

      // The server wraps this as {"message": "Validation failed.",
      // "errors": {"password": ["This password is too common."]}} — the bug
      // was returning only "Validation failed." and dropping the specific
      // reason.
      final registerError = await container
          .read(authControllerProvider.notifier)
          .register(
            username: username,
            email: '$username@example.com',
            password: 'password',
          );

      expect(registerError, isNotNull);
      expect(registerError, isNot(equals('Validation failed.')));
      expect(registerError, contains('password'));
      expect(registerError, contains('too common'));
    },
  );

  test('place and trip sync round-trip against the real server', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    if (!await _serverReachable()) {
      // ignore: avoid_print
      print('Skipping: no live server at $_serverUrl');
      return;
    }

    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        appDatabaseProvider.overrideWithValue(
          AppDatabase.forTesting(NativeDatabase.memory()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(serverConfigProvider.notifier)
        .setServerAddress(_serverUrl);

    final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
    final username = 'flutter_it_trip_$uniqueSuffix';
    final registerError = await container
        .read(authControllerProvider.notifier)
        .register(
          username: username,
          email: '$username@example.com',
          password: 'Sup3rSecretPass!',
        );
    expect(registerError, isNull, reason: 'register failed: $registerError');

    final db = container.read(appDatabaseProvider);
    await db
        .into(db.places)
        .insert(
          PlacesCompanion.insert(
            name: 'Home',
            category: const Value(PlaceCategory.home),
            latitude: 12.34,
            longitude: 56.78,
            source: RecordSource.manual,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
    await db
        .into(db.trips)
        .insert(
          TripsCompanion.insert(
            startedAt: DateTime.now().toUtc(),
            distanceMeters: const Value(1234.5),
            pointCount: const Value(42),
            source: RecordSource.location,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );

    final syncError = await container
        .read(syncControllerProvider.notifier)
        .syncNow();
    expect(syncError, isNull, reason: 'sync failed: $syncError');

    final placeRow = await db.select(db.places).getSingle();
    final tripRow = await db.select(db.trips).getSingle();
    expect(placeRow.syncState, SyncState.synced);
    expect(placeRow.serverRev, isNotNull);
    expect(tripRow.syncState, SyncState.synced);
    expect(tripRow.serverRev, isNotNull);
  });

  test(
    'workout session and note sync round-trip against the real server',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      HttpOverrides.global = null;

      if (!await _serverReachable()) {
        // ignore: avoid_print
        print('Skipping: no live server at $_serverUrl');
        return;
      }

      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          appDatabaseProvider.overrideWithValue(
            AppDatabase.forTesting(NativeDatabase.memory()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(serverConfigProvider.notifier)
          .setServerAddress(_serverUrl);

      final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
      final username = 'flutter_it_workout_$uniqueSuffix';
      final registerError = await container
          .read(authControllerProvider.notifier)
          .register(
            username: username,
            email: '$username@example.com',
            password: 'Sup3rSecretPass!',
          );
      expect(registerError, isNull, reason: 'register failed: $registerError');

      final db = container.read(appDatabaseProvider);
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              activityType: ActivityType.running,
              startedAt: DateTime.now().toUtc(),
              endedAt: Value(DateTime.now().toUtc()),
              distanceMeters: const Value(5000),
              calories: const Value(350),
              notes: const Value('Morning run'),
              source: RecordSource.manual,
              syncState: const Value(SyncState.pendingUpload),
            ),
          );
      await db
          .into(db.notes)
          .insert(
            NotesCompanion.insert(
              content: 'Felt great today',
              noteDate: DateTime.now().toUtc(),
              source: RecordSource.manual,
              syncState: const Value(SyncState.pendingUpload),
            ),
          );

      final syncError = await container
          .read(syncControllerProvider.notifier)
          .syncNow();
      expect(syncError, isNull, reason: 'sync failed: $syncError');

      final workoutRow = await db.select(db.workoutSessions).getSingle();
      final noteRow = await db.select(db.notes).getSingle();
      expect(workoutRow.syncState, SyncState.synced);
      expect(workoutRow.serverRev, isNotNull);
      expect(noteRow.syncState, SyncState.synced);
      expect(noteRow.serverRev, isNotNull);
    },
  );
}
