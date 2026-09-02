import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/domain/meal_period.dart';
import 'package:localbite/domain/opening_hours.dart';
import 'package:localbite/domain/time_range.dart';

void main() {
  // 2026-09-02 is a Wednesday.
  DateTime wed(int hour, [int minute = 0]) =>
      DateTime(2026, 9, 2, hour, minute);

  group('statusAt — simple daytime hours', () {
    final hours = OpeningHours.everyDay(const TimeRange.hm(11, 0, 21, 0));

    test('is open mid-window', () {
      final status = hours.statusAt(wed(14));
      expect(status.isOpen, isTrue);
      expect(status.label(now: wed(14)), 'Closes 9 PM');
    });

    test('is closed before opening, and reports today opening time', () {
      final status = hours.statusAt(wed(9));
      expect(status.isOpen, isFalse);
      expect(status.label(now: wed(9)), 'Opens 11 AM');
    });

    test('is open at the opening minute and closed at the closing minute', () {
      expect(hours.statusAt(wed(11, 0)).isOpen, isTrue);
      expect(hours.statusAt(wed(20, 59)).isOpen, isTrue);
      expect(hours.statusAt(wed(21, 0)).isOpen, isFalse);
    });

    test('after closing, next opening rolls to tomorrow', () {
      final status = hours.statusAt(wed(22));
      expect(status.isOpen, isFalse);
      expect(status.label(now: wed(22)), 'Opens tomorrow 11 AM');
    });
  });

  group('statusAt — hours that wrap past midnight', () {
    // A late-night van trading 18:00 until 03:00.
    final hours = OpeningHours.everyDay(const TimeRange.hm(18, 0, 3, 0));

    test('is open in the evening, closing after midnight', () {
      final status = hours.statusAt(wed(20));
      expect(status.isOpen, isTrue);
      expect(status.changeAt, DateTime(2026, 9, 3, 3));
    });

    test('is open at 01:00 via yesterday\'s trading window', () {
      // The classic failure: 01:00 is outside today's 18:00-03:00 range and
      // only resolves by checking the previous day's wrapped tail.
      final status = hours.statusAt(wed(1));
      expect(status.isOpen, isTrue);
      expect(status.label(now: wed(1)), 'Closes 3 AM');
    });

    test('is closed in the afternoon gap', () {
      final status = hours.statusAt(wed(15));
      expect(status.isOpen, isFalse);
      expect(status.label(now: wed(15)), 'Opens 6 PM');
    });
  });

  group('statusAt — split trading days', () {
    final hours = OpeningHours.everyDay(const TimeRange.hm(7, 0, 11, 0));
    final split = OpeningHours({
      for (var day = DateTime.monday; day <= DateTime.sunday; day++)
        day: const [TimeRange.hm(7, 0, 11, 0), TimeRange.hm(17, 0, 21, 0)],
    });

    test('is closed between the two windows and opens for the second', () {
      final status = split.statusAt(wed(13));
      expect(status.isOpen, isFalse);
      expect(status.label(now: wed(13)), 'Opens 5 PM');
    });

    test('is open in the second window', () {
      expect(split.statusAt(wed(18)).isOpen, isTrue);
      expect(split.statusAt(wed(18)).label(now: wed(18)), 'Closes 9 PM');
    });

    test('single-window vendor still closes correctly', () {
      expect(hours.statusAt(wed(12)).isOpen, isFalse);
    });
  });

  group('statusAt — days with no trading', () {
    // Trades weekdays only. Wednesday 2026-09-02, so Saturday is the 5th.
    final hours = OpeningHours.weekdaysAndWeekend(
      weekdays: const [TimeRange.hm(7, 0, 15, 0)],
      weekend: const [],
    );

    test('names the next trading weekday from a Saturday', () {
      final saturday = DateTime(2026, 9, 5, 12);
      final status = hours.statusAt(saturday);
      expect(status.isOpen, isFalse);
      expect(status.label(now: saturday), 'Opens Mon 7 AM');
    });

    test('reports indefinitely closed when no hours exist at all', () {
      const never = OpeningHours({});
      final status = never.statusAt(wed(12));
      expect(status.isOpen, isFalse);
      expect(status.changeAt, isNull);
      expect(status.label(now: wed(12)), 'Closed');
    });
  });

  group('servesDuring', () {
    test('a breakfast-only stall does not serve dinner', () {
      final hours = OpeningHours.everyDay(const TimeRange.hm(6, 0, 10, 30));
      expect(hours.servesDuring(MealPeriod.breakfast), isTrue);
      expect(hours.servesDuring(MealPeriod.lunch), isFalse);
      expect(hours.servesDuring(MealPeriod.dinner), isFalse);
    });

    test('an overnight stall serves dinner', () {
      final hours = OpeningHours.everyDay(const TimeRange.hm(18, 0, 3, 0));
      expect(hours.servesDuring(MealPeriod.dinner), isTrue);
      expect(hours.servesDuring(MealPeriod.breakfast), isFalse);
    });
  });
}
