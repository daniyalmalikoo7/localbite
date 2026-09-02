/// Small formatting helpers.
///
/// Hand-rolled rather than pulling in `intl`: the spec asks for "9 PM", while
/// `DateFormat.jm()` produces "9:00 PM", so the package would need
/// post-processing anyway for four format strings.
library;

const _weekdayNames = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "9 PM", "9:30 PM", "12 PM", "12 AM".
String formatClockTime(DateTime time) {
  final suffix = time.hour < 12 ? 'AM' : 'PM';
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  if (time.minute == 0) return '$hour12 $suffix';
  return '$hour12:${time.minute.toString().padLeft(2, '0')} $suffix';
}

/// "Mon", "Tue", ... for `DateTime.monday`..`DateTime.sunday`.
String formatWeekday(int weekday) => _weekdayNames[weekday - 1];

/// "850 m" below a kilometre, "1.2 km" above it.
String formatDistance(double metres) {
  if (metres < 1000) {
    final rounded = (metres / 10).round() * 10;
    return '$rounded m';
  }
  return '${(metres / 1000).toStringAsFixed(1)} km';
}

/// "just now", "12 min ago", "3 hours ago", "2 days ago", "1 week ago".
String formatRelativeTime(DateTime then, {required DateTime now}) {
  final diff = now.difference(then);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return _plural(diff.inHours, 'hour');
  if (diff.inDays < 7) return _plural(diff.inDays, 'day');
  if (diff.inDays < 35) return _plural(diff.inDays ~/ 7, 'week');
  return _plural(diff.inDays ~/ 30, 'month');
}

String _plural(int count, String unit) =>
    '$count $unit${count == 1 ? '' : 's'} ago';
