import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  // Functional requirement 1: vendor discovery by location and food type.
  group('Discover filtering', () {
    testWidgets('defaults to every stall ordered by proximity', (tester) async {
      await pumpApp(tester, surface: const Size(390, 1800));

      expect(find.text('Near you'), findsOneWidget);
      // The closest stall leads the list.
      expect(find.text('The Espresso Cart'), findsOneWidget);
    });

    testWidgets('a food-type chip narrows the list', (tester) async {
      await pumpApp(tester, surface: const Size(390, 1800));

      await tester.ensureVisible(find.text('Indian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Indian'));
      await tester.pumpAndSettle();

      expect(find.text('Curry Express'), findsOneWidget);
      expect(find.text('The Espresso Cart'), findsNothing);
      expect(find.text('1 result'), findsOneWidget);
    });

    testWidgets('tapping the active chip again clears the filter', (
      tester,
    ) async {
      await pumpApp(tester, surface: const Size(390, 1800));

      await tester.ensureVisible(find.text('Indian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Indian'));
      await tester.pumpAndSettle();
      expect(find.text('The Espresso Cart'), findsNothing);

      await tester.ensureVisible(find.text('Indian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Indian'));
      await tester.pumpAndSettle();

      expect(find.text('Near you'), findsOneWidget);
      expect(find.text('The Espresso Cart'), findsOneWidget);
    });

    testWidgets('the All chip restores the full list', (tester) async {
      await pumpApp(tester, surface: const Size(390, 1800));

      await tester.ensureVisible(find.text('Mexican'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mexican'));
      await tester.pumpAndSettle();
      expect(find.text('Mama Rosa Tacos'), findsOneWidget);

      await tester.ensureVisible(find.text('All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Near you'), findsOneWidget);
    });
  });
}
