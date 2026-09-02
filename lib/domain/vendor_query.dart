import 'package:flutter/foundation.dart';

import 'food_category.dart';
import 'geo_point.dart';
import 'meal_period.dart';
import 'vendor.dart';

enum VendorSort {
  nearest('Nearest'),
  topRated('Top rated'),
  recent('Recent');

  const VendorSort(this.label);
  final String label;
}

/// The active filter and sort selection.
///
/// Pure and immutable: [applyTo] does no I/O and touches no `BuildContext`, so
/// the whole discovery behaviour is unit-testable without pumping a widget.
@immutable
class VendorQuery {
  const VendorQuery({
    this.searchTerm = '',
    this.categories = const <FoodCategory>{},
    this.maxDistanceMetres,
    this.openNowOnly = false,
    this.sort = VendorSort.nearest,
    this.mealPeriod,
  });

  static const empty = VendorQuery();

  final String searchTerm;
  final Set<FoodCategory> categories;

  /// Null means "any distance".
  final int? maxDistanceMetres;
  final bool openNowOnly;
  final VendorSort sort;

  /// Null means "any time of day".
  final MealPeriod? mealPeriod;

  bool get isDefault =>
      searchTerm.isEmpty &&
      categories.isEmpty &&
      maxDistanceMetres == null &&
      !openNowOnly &&
      sort == VendorSort.nearest &&
      mealPeriod == null;

  /// Drives the badge on the Home search icon.
  int get activeFilterCount => [
    searchTerm.isNotEmpty,
    categories.isNotEmpty,
    maxDistanceMetres != null,
    openNowOnly,
    sort != VendorSort.nearest,
    mealPeriod != null,
  ].where((active) => active).length;

  /// Whether a clock tick can change the *result set*, not just the labels.
  bool get dependsOnClock => openNowOnly;

  List<Vendor> applyTo(
    List<Vendor> vendors, {
    required DateTime now,
    required GeoPoint origin,
  }) {
    final term = searchTerm.trim().toLowerCase();

    final matches = vendors.where((vendor) {
      if (categories.isNotEmpty &&
          !vendor.allCategories.any(categories.contains)) {
        return false;
      }
      if (openNowOnly && !vendor.statusAt(now).isOpen) return false;
      final maxDistance = maxDistanceMetres;
      if (maxDistance != null && vendor.distanceFrom(origin) > maxDistance) {
        return false;
      }
      final period = mealPeriod;
      if (period != null && !vendor.hours.servesDuring(period)) return false;
      if (term.isNotEmpty && !_matchesTerm(vendor, term)) return false;
      return true;
    }).toList();

    matches.sort(switch (sort) {
      VendorSort.nearest => (
        a,
        b,
      ) => a.distanceFrom(origin).compareTo(b.distanceFrom(origin)),
      VendorSort.topRated => (a, b) => b.rating.compareTo(a.rating),
      VendorSort.recent => (a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt),
    });
    return matches;
  }

  static bool _matchesTerm(Vendor vendor, String term) =>
      vendor.name.toLowerCase().contains(term) ||
      vendor.cuisineLabel.toLowerCase().contains(term) ||
      vendor.suburb.toLowerCase().contains(term) ||
      vendor.allCategories.any(
        (category) => category.label.toLowerCase().contains(term),
      );

  /// [clearMaxDistance] and [clearMealPeriod] exist because null is a
  /// meaningful value for those fields ("any"). Without them the usual
  /// `value ?? this.value` idiom makes the "5 km+" and "Any" chips
  /// unselectable — they could set a filter but never clear it.
  VendorQuery copyWith({
    String? searchTerm,
    Set<FoodCategory>? categories,
    int? maxDistanceMetres,
    bool clearMaxDistance = false,
    bool? openNowOnly,
    VendorSort? sort,
    MealPeriod? mealPeriod,
    bool clearMealPeriod = false,
  }) => VendorQuery(
    searchTerm: searchTerm ?? this.searchTerm,
    categories: categories ?? this.categories,
    maxDistanceMetres: clearMaxDistance
        ? null
        : (maxDistanceMetres ?? this.maxDistanceMetres),
    openNowOnly: openNowOnly ?? this.openNowOnly,
    sort: sort ?? this.sort,
    mealPeriod: clearMealPeriod ? null : (mealPeriod ?? this.mealPeriod),
  );

  @override
  bool operator ==(Object other) =>
      other is VendorQuery &&
      other.searchTerm == searchTerm &&
      setEquals(other.categories, categories) &&
      other.maxDistanceMetres == maxDistanceMetres &&
      other.openNowOnly == openNowOnly &&
      other.sort == sort &&
      other.mealPeriod == mealPeriod;

  @override
  int get hashCode => Object.hash(
    searchTerm,
    Object.hashAllUnordered(categories),
    maxDistanceMetres,
    openNowOnly,
    sort,
    mealPeriod,
  );
}
