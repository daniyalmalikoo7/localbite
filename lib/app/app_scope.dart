import 'package:flutter/widgets.dart';

import '../state/catalog_controller.dart';
import '../state/clock_controller.dart';
import '../state/reviews_controller.dart';
import '../state/saved_controller.dart';

/// Makes the four controllers reachable from anywhere in the tree.
///
/// Reads go through `getInheritedWidgetOfExactType`, which does *not* register
/// the caller as a dependent. Reactivity is opt-in per widget via
/// `ListenableBuilder`, so a per-minute clock tick repaints only the badges
/// that display time rather than every screen below the scope.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.clock,
    required this.catalog,
    required this.saved,
    required this.reviews,
    required super.child,
  });

  final ClockController clock;
  final CatalogController catalog;
  final SavedController saved;
  final ReviewsController reviews;

  static AppScope _of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget.');
    return scope!;
  }

  static ClockController clockOf(BuildContext context) => _of(context).clock;
  static CatalogController catalogOf(BuildContext context) =>
      _of(context).catalog;
  static SavedController savedOf(BuildContext context) => _of(context).saved;
  static ReviewsController reviewsOf(BuildContext context) =>
      _of(context).reviews;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      clock != oldWidget.clock ||
      catalog != oldWidget.catalog ||
      saved != oldWidget.saved ||
      reviews != oldWidget.reviews;
}
