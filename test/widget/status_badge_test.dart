import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/domain/opening_hours.dart';
import 'package:localbite/domain/time_range.dart';
import 'package:localbite/widgets/status_badge.dart';

import 'harness.dart';

void main() {
  // Functional requirement 2: real-time open/closed status.
  //
  // The badge reads the shared clock itself, so advancing time repaints it
  // with no navigation, no pull-to-refresh and no rebuild of any parent.
  group('StatusBadge updates live', () {
    final hours = OpeningHours.everyDay(const TimeRange.hm(11, 0, 21, 0));

    testWidgets(
      'flips from OPEN to CLOSED when the clock passes closing time',
      (tester) async {
        final clock = await pumpInScope(
          tester,
          StatusBadge(hours: hours, showChangeLabel: true),
          now: DateTime(2026, 9, 2, 13),
        );

        expect(find.text('OPEN'), findsOneWidget);
        expect(find.text('· Closes 9 PM'), findsOneWidget);

        // Advance past closing. Nothing else is touched.
        clock.setNow(DateTime(2026, 9, 2, 21, 30));
        await tester.pumpAndSettle();

        expect(find.text('CLOSED'), findsOneWidget);
        expect(find.text('OPEN'), findsNothing);
        expect(find.text('· Opens tomorrow 11 AM'), findsOneWidget);
      },
    );

    testWidgets('flips from CLOSED to OPEN at the opening minute', (
      tester,
    ) async {
      final clock = await pumpInScope(
        tester,
        StatusBadge(hours: hours),
        now: DateTime(2026, 9, 2, 10, 59),
      );

      expect(find.text('CLOSED'), findsOneWidget);

      clock.setNow(DateTime(2026, 9, 2, 11));
      await tester.pumpAndSettle();

      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets('an overnight stall reads OPEN after midnight', (tester) async {
      await pumpInScope(
        tester,
        StatusBadge(
          hours: OpeningHours.everyDay(const TimeRange.hm(18, 0, 3, 0)),
          showChangeLabel: true,
        ),
        now: DateTime(2026, 9, 2, 1),
      );

      expect(find.text('OPEN'), findsOneWidget);
      expect(find.text('· Closes 3 AM'), findsOneWidget);
    });
  });
}
