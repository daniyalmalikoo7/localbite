import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/data/repository_exception.dart';
import 'package:localbite/data/seed_data.dart';
import 'package:localbite/data/vendor_repository.dart';
import 'package:localbite/domain/review.dart';
import 'package:localbite/domain/vendor.dart';
import 'package:localbite/widgets/skeleton.dart';

import 'harness.dart';

/// A repository whose failures can be scheduled, so recovery is testable
/// rather than only failure.
class TestRepository implements VendorRepository {
  TestRepository({
    required this.seededAt,
    this.vendorFailuresRemaining = 0,
    this.failSubmit = false,
  });

  final DateTime seededAt;
  int vendorFailuresRemaining;
  bool failSubmit;

  @override
  Future<List<Vendor>> loadVendors() async {
    if (vendorFailuresRemaining > 0) {
      vendorFailuresRemaining--;
      throw const RepositoryException('Network unreachable.');
    }
    return buildSeedVendors(seededAt);
  }

  @override
  Future<List<Review>> loadReviews() async => buildSeedReviews(seededAt);

  @override
  Future<void> submitReview(Review review) async {
    if (failSubmit) {
      throw const RepositoryException(
        "Your review couldn't be posted. It has been kept — try again.",
      );
    }
  }
}

void main() {
  group('loading', () {
    testWidgets('shows skeletons before the data arrives', (tester) async {
      // settle: false catches the frame between mount and the load resolving.
      await pumpApp(tester, settle: false);

      expect(find.byType(VendorCardSkeleton), findsWidgets);
      expect(find.text('The Espresso Cart'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byType(VendorCardSkeleton), findsNothing);
      expect(find.text('The Espresso Cart'), findsOneWidget);
    });
  });

  group('failure and recovery', () {
    testWidgets('a failed load explains itself and offers a way back', (
      tester,
    ) async {
      await pumpApp(tester, failLoads: true);

      expect(find.text("Couldn't load"), findsOneWidget);
      expect(find.textContaining('Check your connection'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // Never a bare empty list pretending nothing exists.
      expect(find.text('No stalls match those filters'), findsNothing);
    });

    testWidgets('Try again recovers after a transient failure', (tester) async {
      final repository = TestRepository(
        seededAt: testInstant,
        vendorFailuresRemaining: 1,
      );
      await pumpApp(tester, repository: repository);

      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Try again'), findsNothing);
      expect(find.text('The Espresso Cart'), findsOneWidget);
    });

    testWidgets('the Saved tab reports the failure too', (tester) async {
      await pumpApp(tester, failLoads: true);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(find.text('Saved spots unavailable'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('submitting a review', () {
    testWidgets('a failed post keeps the sheet open with the text intact', (
      tester,
    ) async {
      final repository = TestRepository(
        seededAt: testInstant,
        failSubmit: true,
      );
      await pumpApp(
        tester,
        repository: repository,
        surface: const Size(390, 1400),
      );

      await tester.tap(find.text("Ahmed's Shawarma").first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Write a Review'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'What was it like?'),
        'Great wrap',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Post review'));
      await tester.pumpAndSettle();

      // Still open, error shown, input preserved.
      expect(find.textContaining("couldn't be posted"), findsOneWidget);
      expect(find.text('Great wrap'), findsOneWidget);
    });

    testWidgets('a successful post closes the sheet and lists the review', (
      tester,
    ) async {
      await pumpApp(tester, surface: const Size(390, 1400));

      await tester.tap(find.text("Ahmed's Shawarma").first);
      await tester.pumpAndSettle();
      expect(find.text('Reviews (4)'), findsOneWidget);

      await tester.tap(find.text('Write a Review'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'What was it like?'),
        'Great wrap',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Post review'));
      await tester.pumpAndSettle();

      expect(find.text('Reviews (5)'), findsOneWidget);
      expect(find.text('Great wrap'), findsOneWidget);
    });
  });
}
