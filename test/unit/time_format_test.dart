import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/domain/time_format.dart';

void main() {
  group('formatClockTime', () {
    test('drops the minutes on the hour', () {
      expect(formatClockTime(DateTime(2026, 9, 2, 21)), '9 PM');
      expect(formatClockTime(DateTime(2026, 9, 2, 7)), '7 AM');
    });

    test('keeps minutes when present', () {
      expect(formatClockTime(DateTime(2026, 9, 2, 21, 30)), '9:30 PM');
      expect(formatClockTime(DateTime(2026, 9, 2, 9, 5)), '9:05 AM');
    });

    test('handles the noon and midnight boundaries', () {
      expect(formatClockTime(DateTime(2026, 9, 2, 12)), '12 PM');
      expect(formatClockTime(DateTime(2026, 9, 2, 0)), '12 AM');
    });
  });

  group('formatDistance', () {
    test('uses metres below a kilometre', () {
      expect(formatDistance(320), '320 m');
      expect(formatDistance(847), '850 m');
    });

    test('uses one decimal kilometre above', () {
      expect(formatDistance(1000), '1.0 km');
      expect(formatDistance(1240), '1.2 km');
    });
  });

  group('formatRelativeTime', () {
    final now = DateTime(2026, 9, 2, 12);

    test('describes recent times', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(seconds: 20)), now: now),
        'just now',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 12)), now: now),
        '12 min ago',
      );
    });

    test('singularises and pluralises correctly', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 1)), now: now),
        '1 hour ago',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 2)), now: now),
        '2 days ago',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 7)), now: now),
        '1 week ago',
      );
    });
  });

  test('formatWeekday names each day', () {
    expect(formatWeekday(DateTime.monday), 'Mon');
    expect(formatWeekday(DateTime.sunday), 'Sun');
  });
}
