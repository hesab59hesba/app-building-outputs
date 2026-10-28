import 'dart:ui' show FontFeature;

const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatHms(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return h > 0 ? '$h:${twoDigits(m)}:${twoDigits(s)}' : '${twoDigits(m)}:${twoDigits(s)}';
}

String formatStopwatch(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  final cs = d.inMilliseconds.remainder(1000) ~/ 10;
  final base = h > 0 ? '$h:${twoDigits(m)}:${twoDigits(s)}' : '${twoDigits(m)}:${twoDigits(s)}';
  return '$base.${twoDigits(cs)}';
}

String formatClock(DateTime t) => '${twoDigits(t.hour)}:${twoDigits(t.minute)}';

String formatClockSeconds(DateTime t) =>
    '${twoDigits(t.hour)}:${twoDigits(t.minute)}:${twoDigits(t.second)}';

String offsetLabel(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs();
  final minutes = offset.inMinutes.remainder(60).abs();
  return minutes == 0 ? '$sign$hours' : '$sign$hours:${twoDigits(minutes)}';
}

const List<String> weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime t) =>
    '${weekdayNames[t.weekday - 1]}, ${monthNames[t.month - 1]} ${t.day}, ${t.year}';
