class SyncTypeCounts {
  const SyncTypeCounts({
    required this.pending,
    required this.failed,
    required this.conflicts,
  });

  final int pending;
  final int failed;
  final int conflicts;

  SyncTypeCounts operator +(SyncTypeCounts other) => SyncTypeCounts(
    pending: pending + other.pending,
    failed: failed + other.failed,
    conflicts: conflicts + other.conflicts,
  );

  static const zero = SyncTypeCounts(pending: 0, failed: 0, conflicts: 0);
}

/// One conflicted record, generalized across syncable types for the
/// conflicts-review UI.
class ConflictSummary {
  const ConflictSummary({
    required this.typeName,
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String typeName;
  final String id;
  final String title;
  final String subtitle;
}

/// Bridges the generic upload/download/conflict-resolution algorithm in
/// [SyncRepository] to one concrete Drift table. Each syncable record type
/// (location_point, health_sample, …) gets a small handler implementing the
/// type-specific wire shape; the actual sync algorithm — batch upload,
/// changed-since download, conflict protection, keep-mine/take-theirs
/// resolution — lives once, in the repository, not copied per type.
abstract class SyncTypeHandler {
  /// Must match the server's `sync.registry.register_syncable` type_name.
  String get typeName;

  /// Rows currently pendingUpload/failed, already serialized to the wire
  /// shape the server expects for `/api/sync/upload/`.
  Future<List<Map<String, dynamic>>> pendingWireRecords();

  /// Apply an upload response's three buckets back onto local rows.
  Future<void> applyUploadResult({
    required List<String> accepted,
    required List<String> conflicts,
    required List<Map<String, dynamic>> rejected,
  });

  /// Upsert one record downloaded from `/api/sync/download/`. Must leave a
  /// row currently in `conflict` state untouched unless
  /// [forceOverwriteConflicts] is true.
  Future<void> upsertDownloaded(
    Map<String, dynamic> json, {
    required bool forceOverwriteConflicts,
  });

  Future<SyncTypeCounts> counts();

  Future<List<ConflictSummary>> conflictSummaries();

  /// Re-upload one record's current local state, forcing an unconditional
  /// server overwrite (omitting base_server_rev) — the "keep mine" conflict
  /// resolution.
  Future<Map<String, dynamic>> wireForForceOverwrite(String id);

  Future<void> markSynced(String id);
}
