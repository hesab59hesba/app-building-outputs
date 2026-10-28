import 'dart:convert';

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as String,
        title: (map['title'] as String?) ?? '',
        body: (map['body'] as String?) ?? '',
        updatedAt:
            DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );

  static String encodeList(List<Note> notes) =>
      jsonEncode(notes.map((note) => note.toMap()).toList());

  static List<Note> decodeList(String raw) {
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => Note.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
