import 'package:flutter/material.dart';

import 'editor_screen.dart';
import 'note.dart';
import 'notes_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.store});

  final NotesStore? store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NotesStore _store = widget.store ?? NotesStore();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _store.dispose();
    super.dispose();
  }

  Future<void> _openEditor({Note? note}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditorScreen(store: _store, note: note),
      ),
    );
  }

  void _deleteNote(Note note) {
    _store.delete(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _store.restore(note),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _preview(Note note) {
    final preview = note.body.trim().split('\n').first.trim();
    return preview.isEmpty ? 'Empty note' : preview;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _store.setQuery,
              decoration: InputDecoration(
                hintText: 'Search notes',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final notes = _store.notes;
          if (notes.isEmpty) {
            return _EmptyState(searching: _store.query.trim().isNotEmpty);
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: ValueKey(note.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline),
                ),
                onDismissed: (_) => _deleteNote(note),
                child: Card(
                  child: ListTile(
                    title: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _preview(note),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatDate(note.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => _openEditor(note: note),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        tooltip: 'New note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            searching ? Icons.search_off : Icons.sticky_note_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            searching ? 'No matching notes' : 'No notes yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            searching
                ? 'Try a different search term'
                : 'Tap + to create your first note',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
