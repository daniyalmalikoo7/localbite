import 'package:flutter/foundation.dart';

import '../data/vendor_repository.dart';
import '../domain/meal_period.dart';
import '../domain/review.dart';

/// Reviews, grouped by vendor and newest first.
class ReviewsController extends ChangeNotifier {
  ReviewsController({required VendorRepository repository})
    : _reviews = [...repository.loadReviews()];

  final List<Review> _reviews;

  /// Newest first, optionally narrowed to one meal period.
  List<Review> forVendor(String vendorId, {MealPeriod? mealPeriod}) {
    final matches =
        _reviews
            .where(
              (review) =>
                  review.vendorId == vendorId &&
                  (mealPeriod == null || review.mealPeriod == mealPeriod),
            )
            .toList()
          ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return List.unmodifiable(matches);
  }

  /// Which meal periods this vendor actually has feedback for. Used to avoid
  /// offering a filter chip that would always return an empty list.
  Set<MealPeriod> periodsWithReviews(String vendorId) => {
    for (final review in _reviews)
      if (review.vendorId == vendorId) review.mealPeriod,
  };

  int countFor(String vendorId) =>
      _reviews.where((review) => review.vendorId == vendorId).length;

  double averageFor(String vendorId) {
    final ratings = _reviews
        .where((review) => review.vendorId == vendorId)
        .map((review) => review.rating);
    if (ratings.isEmpty) return 0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  void addReview(Review review) {
    _reviews.add(review);
    notifyListeners();
  }
}
