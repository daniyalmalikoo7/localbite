import 'package:flutter/foundation.dart';

/// A trading window within a single day, stored as minutes from midnight.
///
/// A range whose end is at or before its start wraps past midnight — a kebab
/// van trading 18:00–03:00 is `TimeRange.hm(18, 0, 3, 0)`.
@immutable
class TimeRange {
  const TimeRange(this.startMinute, this.endMinute);

  const TimeRange.hm(int startHour, int startMinute, int endHour, int endMinute)
    : startMinute = startHour * 60 + startMinute,
      endMinute = endHour * 60 + endMinute;

  final int startMinute;
  final int endMinute;

  bool get wrapsMidnight => endMinute <= startMinute;

  /// Whether [minuteOfDay] falls inside the portion of this range that lies on
  /// the range's own calendar day. The post-midnight tail of a wrapping range
  /// belongs to the *next* day and is tested with [containsWrappedTail].
  bool containsToday(int minuteOfDay) => wrapsMidnight
      ? minuteOfDay >= startMinute
      : minuteOfDay >= startMinute && minuteOfDay < endMinute;

  /// Whether [minuteOfDay] falls in the after-midnight tail of a wrapping
  /// range. Checked against *yesterday's* ranges.
  bool containsWrappedTail(int minuteOfDay) =>
      wrapsMidnight && minuteOfDay < endMinute;

  /// Whether this range overlaps the half-open window `[from, to)`.
  bool overlaps(int from, int to) {
    if (!wrapsMidnight) {
      return startMinute < to && endMinute > from;
    }
    // Wrapping range covers [start, 1440) plus [0, end).
    final headOverlaps = startMinute < to && 1440 > from;
    final tailOverlaps = 0 < to && endMinute > from;
    return headOverlaps || tailOverlaps;
  }

  @override
  bool operator ==(Object other) =>
      other is TimeRange &&
      other.startMinute == startMinute &&
      other.endMinute == endMinute;

  @override
  int get hashCode => Object.hash(startMinute, endMinute);

  @override
  String toString() => 'TimeRange($startMinute-$endMinute)';
}
