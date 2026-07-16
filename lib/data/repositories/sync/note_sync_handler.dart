import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../local/database.dart';
import '../../local/sync_wire.dart';
import '../../local/tables/sync_columns.dart';
import 'sync_type_handler.dart';

class NoteSyncHandler implements SyncTypeHandler {
  NoteSyncHandler(this._db);

  final AppDatabase _db;

  @override
  String get typeName => 'note';

  String _dateOnly(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt.toUtc());

  Map<String, dynamic> _toWire(Note row) {
    return {
      'id': row.id,
      'local_rev': row.localRev,
      if (row.serverRev != null) 'base_server_rev': row.serverRev,
      'sync_state': syncStateToWire(SyncState.synced),
      'source': row.source.name,
      if (row.deletedAt != null)
        'deleted_at': row.deletedAt!.toUtc().toIso8601String(),
      'content': row.content,
      'note_date': _dateOnly(row.noteDate),
      'context': row.context,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pendingWireRecords() async {
    final all = await _db.select(_db.notes).get();
    return all
        .where(
          (r) =>
              r.syncState == SyncState.pendingUpload ||
              r.syncState == SyncState.failed,
        )
        .map(_toWire)
        .toList();
  }

  @override
  Future<void> applyUploadResult({
    required List<String> accepted,
    required List<String> conflicts,
    required List<Map<String, dynamic>> rejected,
  }) async {
    for (final id in accepted) {
      await markSynced(id);
    }
    for (final id in conflicts) {
      await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
        const NotesCompanion(syncState: Value(SyncState.conflict)),
      );
    }
    for (final entry in rejected) {
      final id = entry['id'] as String?;
      if (id == null) continue;
      await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
        const NotesCompanion(syncState: Value(SyncState.failed)),
      );
    }
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      const NotesCompanion(syncState: Value(SyncState.synced)),
    );
  }

  @override
  Future<void> upsertDownloaded(
    Map<String, dynamic> json, {
    required bool forceOverwriteConflicts,
  }) async {
    if (!forceOverwriteConflicts) {
      final existing = await (_db.select(
        _db.notes,
      )..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
      if (existing?.syncState == SyncState.conflict) return;
    }

    await _db
        .into(_db.notes)
        .insertOnConflictUpdate(
          NotesCompanion(
            id: Value(json['id'] as String),
            localRev: Value(json['local_rev'] as int? ?? 0),
            serverRev: Value(json['server_rev'] as int?),
            syncState: Value(syncStateFromWire(json['sync_state'] as String)),
            source: Value(RecordSource.values.byName(json['source'] as String)),
            createdAt: Value(DateTime.parse(json['created_at'] as String)),
            updatedAt: Value(DateTime.parse(json['updated_at'] as String)),
            deletedAt: Value(
              json['deleted_at'] == null
                  ? null
                  : DateTime.parse(json['deleted_at'] as String),
            ),
            content: Value(json['content'] as String),
            noteDate: Value(DateTime.parse(json['note_date'] as String)),
            context: Value(json['context'] as String? ?? ''),
          ),
        );
  }

  @override
  Future<SyncTypeCounts> counts() async {
    final rows = await _db.select(_db.notes).get();
    return SyncTypeCounts(
      pending: rows
          .where(
            (r) =>
                r.syncState == SyncState.pendingUpload ||
                r.syncState == SyncState.localOnly,
          )
          .length,
      failed: rows.where((r) => r.syncState == SyncState.failed).length,
      conflicts: rows.where((r) => r.syncState == SyncState.conflict).length,
    );
  }

  @override
  Future<List<ConflictSummary>> conflictSummaries() async {
    final rows = await (_db.select(
      _db.notes,
    )..where((t) => t.syncState.equalsValue(SyncState.conflict))).get();
    return rows
        .map(
          (r) => ConflictSummary(
            typeName: typeName,
            id: r.id,
            title: r.content.length > 40
                ? '${r.content.substring(0, 40)}…'
                : r.content,
            subtitle: _dateOnly(r.noteDate),
          ),
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> wireForForceOverwrite(String id) async {
    final row = await (_db.select(
      _db.notes,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toWire(row)..remove('base_server_rev');
  }
}
