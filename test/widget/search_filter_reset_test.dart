import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  group('Search & Filter reset', () {
    testWidgets('Reset clears the search box as well as the chips', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ramen');
      await tester.pumpAndSettle();
      expect(find.text('ramen'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // The field must not keep showing a term that is no longer applied.
      expect(find.text('ramen'), findsNothing);
      expect(find.textContaining('Show Results (14)'), findsOneWidget);
    });
  });
}
