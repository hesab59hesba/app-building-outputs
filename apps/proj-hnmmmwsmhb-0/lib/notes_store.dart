import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

class NotesStore extends ChangeNotifier {
  NotesStore({Future<SharedPreferences>? prefs})
      : _prefs = prefs ?? SharedPreferences.getInstance();

  static const String _storageKey = 'simple_notes_v1';

  final Future<SharedPreferences> _prefs;
  List<Note> _notes = [];
  String _query = '';

  String get query => _query;

  List<Note> get notes {
    final sorted = [..._notes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return sorted;
    return sorted
        .where((note) =>
            note.title.toLowerCase().contains(q) ||
            note.body.toLowerCase().contains(q))
        .toList();
  }

  Future<void> load() async {
    final prefs = await _prefs;
    _notes = Note.decodeList(prefs.getString(_storageKey) ?? '[]');
    notifyListeners();
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  Future<void> save({String? id, required String title, required String body}) async {
    final now = DateTime.now();
    final index = id == null ? -1 : _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      _notes[index] = Note(id: id!, title: title, body: body, updatedAt: now);
    } else {
      _notes.add(Note(
        id: 'note-${now.microsecondsSinceEpoch}',
        title: title,
        body: body,
        updatedAt: now,
      ));
    }
    await _persist();
  }

  Future<void> delete(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _persist();
  }

  Future<void> restore(Note note) async {
    if (_notes.any((existing) => existing.id == note.id)) return;
    _notes.add(note);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await _prefs;
    await prefs.setString(_storageKey, Note.encodeList(_notes));
    notifyListeners();
  }
}
