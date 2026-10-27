import 'package:flutter/material.dart';

class Mood {
  const Mood(this.id, this.emoji, this.label, this.color, this.softColor);

  final String id;
  final String emoji;
  final String label;
  final Color color;
  final Color softColor;
}

const List<Mood> kMoods = [
  Mood('great', '😄', 'Great', Color(0xFF43A047), Color(0x2E43A047)),
  Mood('good', '🙂', 'Good', Color(0xFF7CB342), Color(0x2E7CB342)),
  Mood('okay', '😐', 'Okay', Color(0xFFF9A825), Color(0x2EF9A825)),
  Mood('low', '😕', 'Low', Color(0xFFFB8C00), Color(0x2EFB8C00)),
  Mood('rough', '😢', 'Rough', Color(0xFFE53935), Color(0x2EE53935)),
];

Mood? moodById(String? id) {
  if (id == null) return null;
  for (final mood in kMoods) {
    if (mood.id == id) return mood;
  }
  return null;
}

const List<String> kMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String monthDayLabel(DateTime date) => '${kMonthNames[date.month - 1]} ${date.day}';

class MoodStore extends ChangeNotifier {
  static const int numDays = 30;

  MoodStore() : today = _startOfDay(DateTime.now());

  final List<String?> _entries = List<String?>.filled(numDays, null);
  final DateTime today;

  static DateTime _startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime dateFor(int index) => today.subtract(Duration(days: numDays - 1 - index));

  int get todayIndex => numDays - 1;

  Mood? moodAt(int index) => moodById(_entries[index]);

  void setMood(int index, String? moodId) {
    if (_entries[index] == moodId) return;
    _entries[index] = moodId;
    notifyListeners();
  }

  void clearAll() {
    if (loggedCount == 0) return;
    for (var i = 0; i < numDays; i++) {
      _entries[i] = null;
    }
    notifyListeners();
  }

  int get loggedCount => _entries.where((entry) => entry != null).length;

  int countOf(String moodId) => _entries.where((entry) => entry == moodId).length;

  int get streak {
    var count = 0;
    for (var i = numDays - 1; i >= 0; i--) {
      if (_entries[i] == null) break;
      count++;
    }
    return count;
  }
}
