import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/sync_mutation.dart';
import '../local/tables/sync_columns.dart';

class NoteRepository {
  NoteRepository(this._db);

  final AppDatabase _db;

  Future<void> addNote({
    required String content,
    required DateTime noteDate,
    String context = '',
  }) async {
    await _db
        .into(_db.notes)
        .insert(
          NotesCompanion.insert(
            content: content,
            noteDate: noteDate,
            context: Value(context),
            source: RecordSource.manual,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
  }

  Future<void> updateNote(
    String id, {
    String? content,
    DateTime? noteDate,
    String? context,
  }) async {
    final current = await (_db.select(
      _db.notes,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        content: content == null ? const Value.absent() : Value(content),
        noteDate: noteDate == null ? const Value.absent() : Value(noteDate),
        context: context == null ? const Value.absent() : Value(context),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }

  Future<void> deleteNote(String id) async {
    final current = await (_db.select(
      _db.notes,
    )..where((t) => t.id.equals(id))).getSingle();
    final bump = SyncBump(current.localRev);
    await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }
}
