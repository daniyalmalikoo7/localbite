import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/widgets/adaptive_nav.dart';

import 'harness.dart';

void main() {
  group('layout adapts to the window', () {
    testWidgets('small phone uses the bottom navigation bar', (tester) async {
      // iPhone SE.
      await pumpApp(tester, surface: const Size(375, 667));

      expect(find.byType(LocalBiteBottomNav), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('large phone still uses the bottom bar', (tester) async {
      // iPhone 16 Pro Max.
      await pumpApp(tester, surface: const Size(430, 932));

      expect(find.byType(LocalBiteBottomNav), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet switches to a rail and a two-pane layout', (
      tester,
    ) async {
      // iPad Pro 11".
      await pumpApp(tester, surface: const Size(1024, 1366));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(LocalBiteBottomNav), findsNothing);
      // The detail pane starts empty until a stall is picked.
      expect(find.text('Pick a stall'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a stall on tablet fills the detail pane', (
      tester,
    ) async {
      await pumpApp(tester, surface: const Size(1024, 1366));

      await tester.tap(find.text('The Espresso Cart').first);
      await tester.pumpAndSettle();

      // Detail renders beside the list rather than pushing a route.
      expect(find.text('Live Queue'), findsOneWidget);
      expect(find.text('Pick a stall'), findsNothing);
      expect(find.text('Bondi Bakehouse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('landscape phone does not overflow', (tester) async {
      await pumpApp(tester, surface: const Size(844, 390));
      expect(tester.takeException(), isNull);
    });

    testWidgets('enlarged system text does not overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester, surface: const Size(375, 667));

      expect(tester.takeException(), isNull);
      expect(find.text('What are you craving?'), findsOneWidget);
    });
  });
}
