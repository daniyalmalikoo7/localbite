import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/app/app_scope.dart';
import 'package:localbite/app/local_bite_app.dart';
import 'package:localbite/data/vendor_repository.dart';
import 'package:localbite/state/catalog_controller.dart';
import 'package:localbite/state/clock_controller.dart';
import 'package:localbite/state/reviews_controller.dart';
import 'package:localbite/state/saved_controller.dart';
import 'package:localbite/theme/app_theme.dart';

/// Wednesday 2026-09-02, 1 PM — inside lunch, with most stalls trading.
final testInstant = DateTime(2026, 9, 2, 13);

/// Pumps the whole app with a frozen clock and deterministic seed data.
///
/// Latency is zero so tests assert on settled states, not on timing. Pass
/// [failLoads] to exercise the error and retry paths, and [settle] false to
/// catch the app mid-load while the skeletons are showing.
Future<ClockController> pumpApp(
  WidgetTester tester, {
  DateTime? now,
  Size surface = const Size(390, 844),
  bool failLoads = false,
  bool settle = true,
  VendorRepository? repository,
}) async {
  final at = now ?? testInstant;
  tester.view.physicalSize = surface * tester.view.devicePixelRatio;
  addTearDown(tester.view.reset);

  final clock = ClockController(now: () => at);
  await tester.pumpWidget(
    LocalBiteApp(
      repository:
          repository ??
          InMemoryVendorRepository(
            seededAt: at,
            latency: Duration.zero,
            failLoads: failLoads,
          ),
      clock: clock,
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return clock;
}

/// Pumps a single widget inside a real [AppScope], for testing one component
/// in isolation.
Future<ClockController> pumpInScope(
  WidgetTester tester,
  Widget child, {
  DateTime? now,
  Set<String> saved = const {},
}) async {
  final at = now ?? testInstant;
  final repository = InMemoryVendorRepository(
    seededAt: at,
    latency: Duration.zero,
  );
  final clock = ClockController(now: () => at);
  final catalog = CatalogController(repository: repository, clock: clock);
  final reviews = ReviewsController(repository: repository);

  await catalog.load();
  await reviews.load();

  addTearDown(() {
    catalog.dispose();
    reviews.dispose();
    clock.dispose();
  });

  await tester.pumpWidget(
    AppScope(
      clock: clock,
      catalog: catalog,
      saved: SavedController(initial: saved),
      reviews: reviews,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return clock;
}
