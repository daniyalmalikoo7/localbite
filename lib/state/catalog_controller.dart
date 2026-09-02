import 'package:flutter/foundation.dart';

import '../data/repository_exception.dart';
import '../data/vendor_repository.dart';
import '../domain/food_category.dart';
import '../domain/geo_point.dart';
import '../domain/vendor.dart';
import '../domain/vendor_query.dart';
import 'clock_controller.dart';
import 'load_state.dart';

/// Holds the vendor catalogue, its load condition, and the active filters.
///
/// Filtering is memoised into [visibleVendors]; it never runs inside a `build`
/// method, so scrolling does not re-sort the list.
class CatalogController extends ChangeNotifier {
  CatalogController({
    required this.repository,
    required this.clock,
    this.origin = kSydneyCbd,
  }) {
    clock.addListener(_onTick);
  }

  final VendorRepository repository;
  final ClockController clock;
  final GeoPoint origin;

  LoadState<List<Vendor>> _state = const Loading();
  VendorQuery _query = VendorQuery.empty;
  List<Vendor> _visible = const [];

  LoadState<List<Vendor>> get state => _state;
  VendorQuery get query => _query;

  /// Everything loaded, unfiltered. Empty until the first load succeeds.
  List<Vendor> get allVendors => switch (_state) {
    Loaded(:final value) => value,
    _ => const [],
  };

  /// The filtered, sorted result the list renders.
  List<Vendor> get visibleVendors => _visible;

  Future<void> load() async {
    _state = const Loading();
    _visible = const [];
    notifyListeners();
    try {
      final vendors = await repository.loadVendors();
      _state = Loaded(vendors);
      _visible = _compute();
    } on RepositoryException catch (error) {
      _state = LoadFailed(error.message);
      _visible = const [];
    }
    notifyListeners();
  }

  /// Same as [load]; named for the button that calls it.
  Future<void> retry() => load();

  Vendor? vendorById(String id) {
    for (final vendor in allVendors) {
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
      _query.applyTo(allVendors, now: clock.now, origin: origin);

  @override
  void dispose() {
    clock.removeListener(_onTick);
    super.dispose();
  }
}
