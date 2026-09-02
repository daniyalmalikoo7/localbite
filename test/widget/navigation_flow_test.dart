import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/widgets/vendor_card.dart';

import 'harness.dart';

void main() {
  group('the four screens link together', () {
    testWidgets('Home -> vendor card -> Detail -> back -> Home', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.text('What are you craving?'), findsOneWidget);
      expect(find.byType(VendorCard), findsWidgets);

      await tester.tap(find.text('The Espresso Cart').first);
      await tester.pumpAndSettle();

      // On the detail screen.
      expect(find.text('Live Queue'), findsOneWidget);

      // The CTA sits below the fold, so scroll it into view.
      await tester.dragUntilVisible(
        find.text('Write a Review'),
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );
      expect(find.text('Write a Review'), findsOneWidget);

      await tester.dragUntilVisible(
        find.byTooltip('Back'),
        find.byType(CustomScrollView),
        const Offset(0, 300),
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('What are you craving?'), findsOneWidget);
      expect(find.text('Live Queue'), findsNothing);
    });

    testWidgets('Home -> Search & Filter -> Show Results -> filtered Home', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Search & Filter'), findsOneWidget);
      expect(find.text('Food Type'), findsOneWidget);

      await tester.tap(find.text('Mexican').first);
      await tester.pumpAndSettle();

      // The count in the CTA reflects the draft filter.
      expect(find.textContaining('Show Results ('), findsOneWidget);

      await tester.tap(find.textContaining('Show Results ('));
      await tester.pumpAndSettle();

      // Back on Home, now filtered.
      expect(find.text('What are you craving?'), findsOneWidget);
      expect(find.text('Mama Rosa Tacos'), findsOneWidget);
      expect(find.text('The Espresso Cart'), findsNothing);
    });

    testWidgets('Discover and Saved tabs switch and preserve state', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('Saved Vendors'), findsOneWidget);

      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();
      expect(find.text('What are you craving?'), findsOneWidget);
    });

    testWidgets('Saved -> vendor card -> Detail -> back returns to Saved', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Ahmed's Shawarma").first);
      await tester.pumpAndSettle();
      expect(find.text('Live Queue'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Saved Vendors'), findsOneWidget);
    });

    testWidgets('Map and Profile tabs state plainly that they are unbuilt', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();
      expect(find.text('Not implemented in this build.'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Not implemented in this build.'), findsOneWidget);
    });
  });
}
