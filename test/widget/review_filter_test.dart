import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localbite/widgets/filter_chip_button.dart';

import 'harness.dart';

void main() {
  // Functional requirement 3: time-of-day reviews.
  group('Review meal-period filter', () {
    Future<void> openAhmeds(WidgetTester tester) async {
      await pumpApp(tester, surface: const Size(390, 1800));
      await tester.tap(find.text("Ahmed's Shawarma").first);
      await tester.pumpAndSettle();
    }

    testWidgets('shows every review under All', (tester) async {
      await openAhmeds(tester);

      expect(find.text('Reviews (4)'), findsOneWidget);
      expect(find.text('user_123'), findsOneWidget);
      expect(find.text('user_456'), findsOneWidget);
    });

    testWidgets('a meal chip narrows the review list', (tester) async {
      await openAhmeds(tester);

      await tester.tap(find.widgetWithText(FilterChipButton, 'Dinner'));
      await tester.pumpAndSettle();

      // user_456 reviewed at dinner; user_123 at lunch.
      expect(find.text('user_456'), findsOneWidget);
      expect(find.text('user_123'), findsNothing);
    });

    testWidgets('tapping the active meal chip restores every review', (
      tester,
    ) async {
      await openAhmeds(tester);

      await tester.tap(find.widgetWithText(FilterChipButton, 'Lunch'));
      await tester.pumpAndSettle();
      expect(find.text('user_456'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChipButton, 'Lunch'));
      await tester.pumpAndSettle();
      expect(find.text('user_456'), findsOneWidget);
    });
  });
}
