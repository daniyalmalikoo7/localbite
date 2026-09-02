import 'package:flutter/foundation.dart';

import '../data/vendor_repository.dart';
import '../domain/food_category.dart';
import '../domain/geo_point.dart';
import '../domain/vendor.dart';
import '../domain/vendor_query.dart';
import 'clock_controller.dart';

/// Holds the vendor catalogue and the active filter selection.
///
/// Filtering happens here and is memoised into [visibleVendors]; it never runs
/// inside a `build` method, so scrolling does not re-sort the list.
class CatalogController extends ChangeNotifier {
  CatalogController({
    required VendorRepository repository,
    required this.clock,
    this.origin = kSydneyCbd,
  }) : _all = List.unmodifiable(repository.loadVendors()) {
    _visible = _compute();
    clock.addListener(_onTick);
  }

  final ClockController clock;
  final GeoPoint origin;
  final List<Vendor> _all;

  VendorQuery _query = VendorQuery.empty;
  late List<Vendor> _visible;

  List<Vendor> get allVendors => _all;
  List<Vendor> get visibleVendors => _visible;
  VendorQuery get query => _query;

  Vendor? vendorById(String id) {
    for (final vendor in _all) {
      if (vendor.id == id) return vendor;
    }
    return null;
  }

  List<Vendor> vendorsByIds(Iterable<String> ids) => [
    for (final id in ids) ?vendorById(id),
  ];

  void applyQuery(VendorQuery next) {
    if (next == _query) return;
    _query = next;
    _visible = _compute();
    notifyListeners();
  }

  /// Home chip row: selecting a category replaces the selection, and tapping
  /// the active one clears it back to "All".
  void selectCategory(FoodCategory? category) {
    applyQuery(
      _query.copyWith(categories: category == null ? const {} : {category}),
    );
  }

  void setSearchTerm(String term) =>
      applyQuery(_query.copyWith(searchTerm: term));

  void clearFilters() => applyQuery(VendorQuery.empty);

  /// A clock tick only changes the *result set* when a filter depends on the
  /// time. The list-equality guard stops an unchanged result from waking the
  /// whole vendor list every minute.
  void _onTick() {
    if (!_query.dependsOnClock) return;
    final next = _compute();
    if (listEquals(next, _visible)) return;
    _visible = next;
    notifyListeners();
  }

  List<Vendor> _compute() =>
      _query.applyTo(_all, now: clock.now, origin: origin);

  @override
  void dispose() {
    clock.removeListener(_onTick);
    super.dispose();
  }
}
