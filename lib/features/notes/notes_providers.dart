import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(appDatabaseProvider));
});

final notesProvider = StreamProvider<List<Note>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.notes)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.noteDate)]))
      .watch();
});
