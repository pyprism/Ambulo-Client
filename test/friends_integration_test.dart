// Exercises Phase 4 (friend requests, accept, location-sharing toggle,
// friends' latest positions, in-app notifications) against a live Ambulo
// server. Requires `./scripts/dockerless_run.sh runserver` running in
// ../Ambulo on 127.0.0.1:8000; skipped automatically if unreachable.
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ambulo/core/server/server_config_controller.dart';
import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/database_provider.dart';
import 'package:ambulo/data/local/secure_token_storage.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/data/repositories/friend_repository.dart';
import 'package:ambulo/features/auth/auth_controller.dart';
import 'package:ambulo/features/friends/friends_providers.dart';
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
    final request = await client.getUrl(Uri.parse('$_serverUrl/api/healthz/'));
    final response = await request.close().timeout(const Duration(seconds: 6));
    return response.statusCode == 200 || response.statusCode == 503;
  } catch (_) {
    return false;
  }
}

Future<ProviderContainer> _signedInContainer(String username) async {
  final container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      appDatabaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
    ],
  );
  await container
      .read(serverConfigProvider.notifier)
      .setServerAddress(_serverUrl);
  final error = await container
      .read(authControllerProvider.notifier)
      .register(
        username: username,
        email: '$username@example.com',
        password: 'Sup3rSecretPass!',
      );
  expect(error, isNull, reason: 'register failed for $username: $error');
  return container;
}

void main() {
  test('friend request, accept, share toggle, and poll-based location sharing '
      'against the real server', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    if (!await _serverReachable()) {
      // ignore: avoid_print
      print('Skipping: no live server at $_serverUrl');
      return;
    }

    SharedPreferences.setMockInitialValues({});

    final suffix = DateTime.now().microsecondsSinceEpoch;
    final usernameA = 'flutter_friend_a_$suffix';
    final usernameB = 'flutter_friend_b_$suffix';

    final containerA = await _signedInContainer(usernameA);
    final containerB = await _signedInContainer(usernameB);
    addTearDown(containerA.dispose);
    addTearDown(containerB.dispose);

    // A sends a request to B by username.
    final friendRepoA = containerA.read(friendRepositoryProvider);
    final friendRepoB = containerB.read(friendRepositoryProvider);

    final sent = await friendRepoA.sendRequest(username: usernameB);
    expect(sent.status, FriendshipStatus.pending);

    // B should see it as an incoming request, and a friend_request
    // notification.
    final bFriendships = await friendRepoB.listFriendships();
    final incoming = bFriendships.singleWhere(
      (f) => f.isIncomingRequest(usernameB),
    );
    expect(incoming.otherUsername(usernameB), usernameA);

    final bNotifications = await friendRepoB.listNotifications();
    expect(
      bNotifications.any(
        (n) =>
            n.type == AppNotificationType.friendRequest &&
            n.payload['from_username'] == usernameA,
      ),
      isTrue,
    );

    // B accepts.
    final accepted = await friendRepoB.accept(incoming.id);
    expect(accepted.status, FriendshipStatus.accepted);

    // A seeds and syncs a location point; sharing defaults on, so B
    // should see it via the poll-based friends'-locations endpoint.
    final dbA = containerA.read(appDatabaseProvider);
    await dbA
        .into(dbA.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: 10.0,
            longitude: 20.0,
            recordedAt: DateTime.now().toUtc(),
            monitoringMode: MonitoringMode.significant,
            syncState: const Value(SyncState.pendingUpload),
            source: RecordSource.location,
          ),
        );
    final syncErrorA = await containerA
        .read(syncControllerProvider.notifier)
        .syncNow();
    expect(syncErrorA, isNull, reason: 'sync failed: $syncErrorA');

    final locationsForB = await friendRepoB.friendLocations();
    final aLocation = locationsForB.singleWhere((l) => l.username == usernameA);
    expect(aLocation.latitude, 10.0);
    expect(aLocation.longitude, 20.0);

    // A turns sharing off; B should no longer see A's location.
    final aFriendships = await friendRepoA.listFriendships();
    final fromA = aFriendships.singleWhere(
      (f) => f.otherUsername(usernameA) == usernameB,
    );
    await friendRepoA.setShare(fromA.id, false);

    final locationsForBAfter = await friendRepoB.friendLocations();
    expect(locationsForBAfter.any((l) => l.username == usernameA), isFalse);
  });

  test('location retention days round-trips through the real server', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    if (!await _serverReachable()) {
      // ignore: avoid_print
      print('Skipping: no live server at $_serverUrl');
      return;
    }

    SharedPreferences.setMockInitialValues({});
    final container = await _signedInContainer(
      'flutter_retention_${DateTime.now().microsecondsSinceEpoch}',
    );
    addTearDown(container.dispose);

    final error = await container
        .read(authControllerProvider.notifier)
        .setLocationRetentionDays(30);
    expect(error, isNull);
    expect(
      container.read(authControllerProvider).value!.locationRetentionDays,
      30,
    );

    final clearError = await container
        .read(authControllerProvider.notifier)
        .setLocationRetentionDays(null);
    expect(clearError, isNull);
    expect(
      container.read(authControllerProvider).value!.locationRetentionDays,
      isNull,
    );
  });
}
