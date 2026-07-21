import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/sync_repository.dart';
import '../auth/auth_controller.dart';
import '../fitness/fitness_providers.dart';
import '../friends/friends_providers.dart';
import '../timeline/trip_history_provider.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(ref.watch(appDatabaseProvider), ref.watch(dioProvider));
});

/// Manual "Sync now" plus the counts the sync status UI shows.
class SyncController extends AsyncNotifier<SyncCounts> {
  @override
  Future<SyncCounts> build() {
    return ref.read(syncRepositoryProvider).counts();
  }

  /// Returns null on success, or a user-facing error message.
  Future<String?> syncNow() async {
    if (ref.read(authControllerProvider).value == null) {
      return 'Sign in to sync with a server.';
    }
    final repo = ref.read(syncRepositoryProvider);
    state = const AsyncLoading();
    try {
      final counts = await repo.syncNow();
      state = AsyncData(counts);
      // Friend sharing is poll-based, never push — a manual sync is the
      // natural moment to also refresh it.
      ref.invalidate(friendshipsProvider);
      ref.invalidate(friendLocationsProvider);
      ref.invalidate(notificationsProvider);
      // Fitness stats are point-in-time queries, not reactive to the tables
      // they read — without this, newly-downloaded steps/activity stay
      // invisible on the dashboard until the app restarts. Trip time is
      // usually caught by its own reactive stream when a trip is
      // downloaded, but a sync with no new trips (e.g. right after
      // midnight) still needs the clock re-read to roll over to today.
      ref.invalidate(todayStatsProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(monthlyStatsProvider);
      ref.invalidate(todayTripTimeMinutesProvider);
      return null;
    } catch (e) {
      state = AsyncData(await repo.counts());
      return e is DioException ? describeDioError(e) : e.toString();
    }
  }

  /// Returns null on success, or a user-facing error message.
  Future<String?> resolveKeepMine(String typeName, String id) async {
    final repo = ref.read(syncRepositoryProvider);
    try {
      await repo.resolveKeepMine(typeName, id);
      state = AsyncData(await repo.counts());
      return null;
    } catch (e) {
      return e is DioException ? describeDioError(e) : e.toString();
    }
  }

  /// Returns null on success, or a user-facing error message.
  Future<String?> resolveAllTakeTheirs(String typeName) async {
    final repo = ref.read(syncRepositoryProvider);
    try {
      await repo.resolveAllTakeTheirs(typeName);
      state = AsyncData(await repo.counts());
      return null;
    } catch (e) {
      return e is DioException ? describeDioError(e) : e.toString();
    }
  }
}

final syncControllerProvider =
    AsyncNotifierProvider<SyncController, SyncCounts>(SyncController.new);
