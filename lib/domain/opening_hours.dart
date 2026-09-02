import 'package:flutter/foundation.dart';

import 'meal_period.dart';
import 'time_range.dart';
import 'vendor_status.dart';

/// A vendor's trading hours, keyed by `DateTime.monday`..`DateTime.sunday`.
///
/// Vendors update these themselves; nothing is scraped from a register. A day
/// with no entry is a day the stall does not trade.
@immutable
class OpeningHours {
  const OpeningHours(this.byWeekday);

  /// The same window every day of the week.
  factory OpeningHours.everyDay(TimeRange range) => OpeningHours({
    for (var day = DateTime.monday; day <= DateTime.sunday; day++) day: [range],
  });

  /// Separate weekday and weekend windows.
  factory OpeningHours.weekdaysAndWeekend({
    required List<TimeRange> weekdays,
    required List<TimeRange> weekend,
  }) => OpeningHours({
    DateTime.monday: weekdays,
    DateTime.tuesday: weekdays,
    DateTime.wednesday: weekdays,
    DateTime.thursday: weekdays,
    DateTime.friday: weekdays,
    DateTime.saturday: weekend,
    DateTime.sunday: weekend,
  });

  final Map<int, List<TimeRange>> byWeekday;

  List<TimeRange> rangesOn(int weekday) => byWeekday[weekday] ?? const [];

  /// Whether the stall trades at any point during [period] on any day. Backs
  /// the "Time of day" filter on the Search & Filter screen.
  bool servesDuring(MealPeriod period) => byWeekday.values.any(
    (ranges) => ranges.any(
      (range) => range.overlaps(period.startMinute, period.endMinute),
    ),
  );

  /// Derives open/closed state and the next transition.
  ///
  /// Day arithmetic goes through the `DateTime` constructor rather than
  /// `Duration`, so a daylight-saving transition shifts the wall clock
  /// correctly instead of sliding every time by an hour.
  VendorStatus statusAt(DateTime now) {
    final minuteOfDay = now.hour * 60 + now.minute;

    // 1. Yesterday's post-midnight tail. Checked first: a stall trading
    //    18:00-03:00 is open at 01:00, and that range belongs to yesterday.
    final yesterday = now.weekday == DateTime.monday
        ? DateTime.sunday
        : now.weekday - 1;
    for (final range in rangesOn(yesterday)) {
      if (range.containsWrappedTail(minuteOfDay)) {
        return VendorStatus.open(_at(now, 0, range.endMinute));
      }
    }

    // 2. Open in one of today's windows.
    for (final range in rangesOn(now.weekday)) {
      if (range.containsToday(minuteOfDay)) {
        final closes = range.wrapsMidnight
            ? _at(now, 1, range.endMinute)
            : _at(now, 0, range.endMinute);
        return VendorStatus.open(closes);
      }
    }

    // 3. Closed, but opening again later today.
    final laterToday =
        rangesOn(now.weekday)
            .map((range) => range.startMinute)
            .where((start) => start > minuteOfDay)
            .toList()
          ..sort();
    if (laterToday.isNotEmpty) {
      return VendorStatus.closed(_at(now, 0, laterToday.first));
    }

    // 4. Closed for the rest of today — find the next trading day.
    for (var offset = 1; offset <= 7; offset++) {
      final weekday = ((now.weekday - 1 + offset) % 7) + 1;
      final ranges = rangesOn(weekday);
      if (ranges.isEmpty) continue;
      final earliest = ranges
          .map((range) => range.startMinute)
          .reduce((a, b) => a < b ? a : b);
      return VendorStatus.closed(_at(now, offset, earliest));
    }

    return const VendorStatus.indefinitelyClosed();
  }

  static DateTime _at(DateTime day, int dayOffset, int minutes) =>
      DateTime(day.year, day.month, day.day + dayOffset, 0, minutes);
}
