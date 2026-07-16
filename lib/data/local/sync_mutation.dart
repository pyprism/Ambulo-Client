import 'package:drift/drift.dart';

import 'tables/sync_columns.dart';

/// Every local write to a syncable row must bump `updatedAt` and
/// `localRev`, and mark it `pendingUpload` — miss one and the edit either
/// looks like it never happened (stale `updatedAt`) or the client's own
/// revision counter (`local_rev`, "carried through for conflict
/// comparison" per the server's `SyncableModel` docstring) silently stops
/// incrementing. Centralized here so call sites can't forget one.
///
/// Takes the row's *current* `localRev` (read immediately before the
/// write — this app is single-writer-per-device, so there's no concurrent-
/// increment race to guard against) and produces the three fields to
/// splice into that table's `Companion`.
class SyncBump {
  SyncBump(int previousLocalRev)
    : updatedAt = Value(DateTime.now()),
      localRev = Value(previousLocalRev + 1),
      syncState = const Value(SyncState.pendingUpload);

  final Value<DateTime> updatedAt;
  final Value<int> localRev;
  final Value<SyncState> syncState;
}
