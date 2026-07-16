import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/local/database.dart';
import '../../shared/widgets/empty_state.dart';
import 'notes_providers.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load notes',
          message: '$e',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.notes_outlined,
              title: 'No notes yet',
              message: 'Jot down anything worth remembering about your day.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _NoteTile(note: items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add note'),
      ),
    );
  }
}

class _NoteTile extends ConsumerWidget {
  const _NoteTile({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(note.content, maxLines: 3, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        note.context.isEmpty
            ? DateFormat.yMMMd().format(note.noteDate)
            : '${DateFormat.yMMMd().format(note.noteDate)} · ${note.context}',
      ),
      onTap: () => _showNoteEditor(context, ref, existing: note),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showNoteEditor(context, ref, existing: note);
          } else if (value == 'delete') {
            _confirmDeleteNote(context, ref, note.id);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteNote(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete this note?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(noteRepositoryProvider).deleteNote(id);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete note: $e')));
    }
  }
}

Future<void> _showNoteEditor(
  BuildContext context,
  WidgetRef ref, {
  Note? existing,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _NoteEditorDialog(existing: existing),
  );
}

class _NoteEditorDialog extends ConsumerStatefulWidget {
  const _NoteEditorDialog({this.existing});

  final Note? existing;

  @override
  ConsumerState<_NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends ConsumerState<_NoteEditorDialog> {
  late final _content = TextEditingController(text: widget.existing?.content);
  late final _context = TextEditingController(text: widget.existing?.context);
  late DateTime _noteDate = widget.existing?.noteDate ?? DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _content.dispose();
    _context.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _noteDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _noteDate = picked);
  }

  Future<void> _save() async {
    if (_content.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note cannot be empty')));
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(noteRepositoryProvider);
      if (widget.existing == null) {
        await repo.addNote(
          content: _content.text.trim(),
          noteDate: _noteDate,
          context: _context.text.trim(),
        );
      } else {
        await repo.updateNote(
          widget.existing!.id,
          content: _content.text.trim(),
          noteDate: _noteDate,
          context: _context.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save note: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add note' : 'Edit note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _content,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _context,
              decoration: const InputDecoration(
                labelText: 'Context (optional)',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(DateFormat.yMMMd().format(_noteDate)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
