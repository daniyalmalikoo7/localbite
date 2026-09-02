import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  // Functional requirement 4: saved vendors with live status.
  group('Saving a vendor', () {
    testWidgets('opens with the two pre-saved stalls', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(find.text('2 saved spots'), findsOneWidget);
      expect(find.text("Ahmed's Shawarma"), findsOneWidget);
      expect(find.text('Street Ramen Co.'), findsOneWidget);
    });

    testWidgets('the heart on Detail adds a stall to Saved', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('The Espresso Cart').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Save this stall'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove from saved'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(find.text('3 saved spots'), findsOneWidget);
      expect(find.text('The Espresso Cart'), findsOneWidget);
    });

    testWidgets('the heart on a Saved card removes it', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('2 saved spots'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove from saved').first);
      await tester.pumpAndSettle();

      expect(find.text('1 saved spot'), findsOneWidget);
    });

    testWidgets('saved cards still show live trading status', (tester) async {
      final clock = await pumpApp(tester);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('OPEN'), findsNWidgets(2));

      // 3 AM: both saved stalls are shut.
      clock.setNow(DateTime(2026, 9, 3, 3));
      await tester.pump();

      expect(find.text('OPEN'), findsNothing);
      expect(find.text('CLOSED'), findsNWidgets(2));
    });
  });
}
