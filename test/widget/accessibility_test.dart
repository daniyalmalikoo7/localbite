import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/widgets/filter_chip_button.dart';

import 'harness.dart';

void main() {
  group('assistive technology can operate the controls', () {
    testWidgets('filter chips expose a tap action, not just a label', (
      tester,
    ) async {
      await pumpApp(tester, surface: const Size(390, 844));
      final handle = tester.ensureSemantics();

      // excludeSemantics around an InkWell silently drops the tap action;
      // this asserts the control is actually activatable, not merely labelled.
      final chip = find.widgetWithText(FilterChipButton, 'Asian');
      expect(
        tester.getSemantics(chip),
        matchesSemantics(
          label: 'Asian',
          isButton: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('bottom navigation tabs expose a tap action', (tester) async {
      await pumpApp(tester, surface: const Size(390, 844));
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.text('Saved')),
        matchesSemantics(
          label: 'Saved',
          isButton: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('meets the tap-target and contrast guidelines on Discover', (
      tester,
    ) async {
      await pumpApp(tester, surface: const Size(390, 844));
      final handle = tester.ensureSemantics();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('layout survives the smallest supported phone', () {
    testWidgets('no overflow at 320dp with double text scale', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester, surface: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the unbuilt tabs stay readable at 320dp and double scale', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester, surface: const Size(320, 568));

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
