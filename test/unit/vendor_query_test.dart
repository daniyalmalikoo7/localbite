import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/domain/food_category.dart';
import 'package:localbite/domain/geo_point.dart';
import 'package:localbite/domain/meal_period.dart';
import 'package:localbite/domain/opening_hours.dart';
import 'package:localbite/domain/time_range.dart';
import 'package:localbite/domain/vendor.dart';
import 'package:localbite/domain/vendor_query.dart';

void main() {
  final now = DateTime(2026, 9, 2, 13); // Wednesday 1 PM

  Vendor vendor({
    required String id,
    required String name,
    required FoodCategory category,
    required double rating,
    required GeoPoint at,
    OpeningHours? hours,
    DateTime? updated,
  }) => Vendor(
    id: id,
    name: name,
    primaryCategory: category,
    cuisineLabel: category.label,
    suburb: 'Sydney CBD',
    emoji: category.emoji,
    location: at,
    rating: rating,
    reviewCount: 10,
    hours: hours ?? OpeningHours.everyDay(const TimeRange.hm(11, 0, 21, 0)),
    baseQueueMinutes: 5,
    lastUpdatedAt: updated ?? DateTime(2026, 9, 1),
  );

  // Roughly 100 m, 300 m and 2 km north of the origin.
  final near = vendor(
    id: 'near',
    name: 'Near Noodles',
    category: FoodCategory.asian,
    rating: 4.0,
    at: const GeoPoint(-33.8728, 151.2069),
    updated: DateTime(2026, 9, 1, 8),
  );
  final mid = vendor(
    id: 'mid',
    name: 'Mid Tacos',
    category: FoodCategory.mexican,
    rating: 4.8,
    at: const GeoPoint(-33.8710, 151.2069),
    updated: DateTime(2026, 9, 1, 20),
  );
  final far = vendor(
    id: 'far',
    name: 'Far Burgers',
    category: FoodCategory.burgers,
    rating: 4.5,
    at: const GeoPoint(-33.8557, 151.2069),
    hours: OpeningHours.everyDay(const TimeRange.hm(6, 0, 10, 0)),
    updated: DateTime(2026, 9, 1, 14),
  );
  final all = [far, mid, near];

  List<Vendor> run(VendorQuery query) =>
      query.applyTo(all, now: now, origin: kSydneyCbd);

  group('filtering', () {
    test('no filters returns everything', () {
      expect(run(VendorQuery.empty), hasLength(3));
    });

    test('category filter narrows to matching vendors', () {
      final result = run(
        const VendorQuery(categories: {FoodCategory.mexican}),
      );
      expect(result.map((v) => v.id), ['mid']);
    });

    test('multiple categories are an OR', () {
      final result = run(
        const VendorQuery(
          categories: {FoodCategory.mexican, FoodCategory.burgers},
        ),
      );
      expect(result.map((v) => v.id), containsAll(['mid', 'far']));
      expect(result, hasLength(2));
    });

    test('open-now filter excludes closed vendors', () {
      // "far" trades 06:00-10:00 and is shut at 1 PM.
      final result = run(const VendorQuery(openNowOnly: true));
      expect(result.map((v) => v.id), isNot(contains('far')));
      expect(result, hasLength(2));
    });

    test('distance filter excludes vendors beyond the radius', () {
      final result = run(const VendorQuery(maxDistanceMetres: 500));
      expect(result.map((v) => v.id), containsAll(['near', 'mid']));
      expect(result, hasLength(2));
    });

    test('meal-period filter uses trading hours', () {
      final result = run(const VendorQuery(mealPeriod: MealPeriod.dinner));
      expect(result.map((v) => v.id), isNot(contains('far')));
    });

    test('search term matches name, cuisine and category', () {
      expect(run(const VendorQuery(searchTerm: 'tacos')).single.id, 'mid');
      expect(run(const VendorQuery(searchTerm: 'ASIAN')).single.id, 'near');
      expect(run(const VendorQuery(searchTerm: 'zzz')), isEmpty);
    });

    test('filters combine as an AND', () {
      final result = run(
        const VendorQuery(
          categories: {FoodCategory.asian, FoodCategory.mexican},
          maxDistanceMetres: 200,
        ),
      );
      expect(result.map((v) => v.id), ['near']);
    });
  });

  group('sorting', () {
    test('nearest orders by distance ascending', () {
      final result = run(const VendorQuery());
      expect(result.map((v) => v.id), ['near', 'mid', 'far']);
    });

    test('top rated orders by rating descending', () {
      final result = run(const VendorQuery(sort: VendorSort.topRated));
      expect(result.map((v) => v.id), ['mid', 'far', 'near']);
    });

    test('recent orders by last listing update descending', () {
      final result = run(const VendorQuery(sort: VendorSort.recent));
      expect(result.map((v) => v.id), ['mid', 'far', 'near']);
    });
  });

  group('copyWith', () {
    test('sets values', () {
      final query = VendorQuery.empty.copyWith(
        maxDistanceMetres: 1000,
        mealPeriod: MealPeriod.lunch,
        openNowOnly: true,
      );
      expect(query.maxDistanceMetres, 1000);
      expect(query.mealPeriod, MealPeriod.lunch);
      expect(query.openNowOnly, isTrue);
    });

    test('clears the nullable fields when asked', () {
      // Without the explicit clear flags these two filters could be set but
      // never unset, so the "5 km+" and "Any" chips would do nothing.
      final query = VendorQuery.empty
          .copyWith(maxDistanceMetres: 1000, mealPeriod: MealPeriod.lunch)
          .copyWith(clearMaxDistance: true, clearMealPeriod: true);
      expect(query.maxDistanceMetres, isNull);
      expect(query.mealPeriod, isNull);
    });

    test('leaves untouched fields alone', () {
      final query = const VendorQuery(
        searchTerm: 'ramen',
        sort: VendorSort.topRated,
      ).copyWith(openNowOnly: true);
      expect(query.searchTerm, 'ramen');
      expect(query.sort, VendorSort.topRated);
    });
  });

  group('metadata', () {
    test('empty query is the default', () {
      expect(VendorQuery.empty.isDefault, isTrue);
      expect(VendorQuery.empty.activeFilterCount, 0);
      expect(VendorQuery.empty.dependsOnClock, isFalse);
    });

    test('counts each active filter dimension once', () {
      const query = VendorQuery(
        searchTerm: 'x',
        categories: {FoodCategory.asian},
        openNowOnly: true,
      );
      expect(query.activeFilterCount, 3);
      expect(query.isDefault, isFalse);
      expect(query.dependsOnClock, isTrue);
    });

    test('equality is by value so identical queries compare equal', () {
      const a = VendorQuery(categories: {FoodCategory.asian}, openNowOnly: true);
      const b = VendorQuery(categories: {FoodCategory.asian}, openNowOnly: true);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
