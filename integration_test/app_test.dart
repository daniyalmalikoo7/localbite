import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localbite/app/local_bite_app.dart';
import 'package:localbite/widgets/filter_chip_button.dart';

/// End-to-end tests: the real app, the real repository with its real latency,
/// and a real ticking clock, driven on a device.
///
/// Run with:
///   `flutter test integration_test/app_test.dart -d <device-id>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps until [finder] matches or the budget runs out.
  ///
  /// `pumpAndSettle` cannot be used while data is loading: the skeleton pulses
  /// continuously, so there is always a frame pending and settle never returns.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Timed out waiting for: ${finder.describeMatch(Plurality.one)}');
  }

  /// [waitFor] plus a settle, so any in-flight route transition finishes
  /// before the next interaction.
  Future<void> waitForSettled(WidgetTester tester, Finder finder) async {
    await waitFor(tester, finder);
    await tester.pumpAndSettle();
  }

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const LocalBiteApp());
    // The list only appears once the (deliberately latent) load resolves.
    await waitForSettled(tester, find.text('The Espresso Cart'));
  }

  group('LocalBite end to end', () {
    testWidgets('loads the stall list from a cold start', (tester) async {
      await launch(tester);

      expect(find.text('What are you craving?'), findsOneWidget);
      expect(find.text('Near you'), findsOneWidget);
      // Live trading status is present, derived from the real clock.
      expect(
        find.textContaining('OPEN').evaluate().isNotEmpty ||
            find.textContaining('CLOSED').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Discover to Vendor Detail and back', (tester) async {
      await launch(tester);

      await tester.tap(find.text("Ahmed's Shawarma").first);
      await waitForSettled(tester, find.text('Live Queue'));

      expect(find.textContaining('Reviews ('), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('What are you craving?'), findsOneWidget);
    });

    testWidgets('filters reviews by meal period', (tester) async {
      await launch(tester);

      await tester.tap(find.text("Ahmed's Shawarma").first);
      await waitForSettled(tester, find.text('Live Queue'));

      await tester.dragUntilVisible(
        find.text('user_123'),
        find.byType(CustomScrollView),
        const Offset(0, -250),
      );
      expect(find.text('user_123'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChipButton, 'Dinner'));
      await tester.pumpAndSettle();
      expect(find.text('user_123'), findsNothing);
    });

    testWidgets('applies a filter through Search and Filter', (tester) async {
      await launch(tester);

      await tester.tap(find.text('Search for food or vendor...'));
      await tester.pumpAndSettle();
      expect(find.text('Search & Filter'), findsOneWidget);

      await tester.tap(find.text('Mexican').first);
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Show Results ('));
      await tester.pumpAndSettle();

      expect(find.text('Mama Rosa Tacos'), findsOneWidget);
      expect(find.text('The Espresso Cart'), findsNothing);
    });

    testWidgets('saves a stall and finds it on the Saved tab', (tester) async {
      await launch(tester);

      await tester.tap(find.text('The Espresso Cart').first);
      await waitForSettled(tester, find.text('Live Queue'));

      debugPrint(
        'BEFORE >>> save=${find.byTooltip('Save this stall').evaluate().length} '
        'remove=${find.byTooltip('Remove from saved').evaluate().length}',
      );
      await tester.tap(find.byTooltip('Save this stall'));
      await tester.pumpAndSettle();
      debugPrint(
        'AFTER  >>> save=${find.byTooltip('Save this stall').evaluate().length} '
        'remove=${find.byTooltip('Remove from saved').evaluate().length}',
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(find.text('3 saved spots'), findsOneWidget);
      expect(find.text('The Espresso Cart'), findsOneWidget);
    });
  });
}
