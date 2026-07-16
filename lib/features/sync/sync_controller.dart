import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/sync_repository.dart';
import '../auth/auth_controller.dart';
import '../friends/friends_providers.dart';

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
