import 'package:flutter/foundation.dart';

import '../data/repository_exception.dart';
import '../data/vendor_repository.dart';
import '../domain/meal_period.dart';
import '../domain/review.dart';
import 'load_state.dart';

/// Reviews, grouped by vendor and newest first.
class ReviewsController extends ChangeNotifier {
  ReviewsController({required this.repository});

  final VendorRepository repository;

  LoadState<List<Review>> _state = const Loading();
  final List<Review> _reviews = [];

  LoadState<List<Review>> get state => _state;

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    try {
      final reviews = await repository.loadReviews();
      _reviews
        ..clear()
        ..addAll(reviews);
      _state = Loaded(List.unmodifiable(_reviews));
    } on RepositoryException catch (error) {
      _state = LoadFailed(error.message);
    }
    notifyListeners();
  }

  Future<void> retry() => load();

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

  /// Which meal periods this vendor has feedback for. Used to avoid offering a
  /// filter chip that would always return an empty list.
  Set<MealPeriod> periodsWithReviews(String vendorId) => {
    for (final review in _reviews)
      if (review.vendorId == vendorId) review.mealPeriod,
  };

  int countFor(String vendorId) =>
      _reviews.where((review) => review.vendorId == vendorId).length;

  /// Sends the review, then adds it locally only once the write succeeded —
  /// so a failure never leaves a phantom review in the list.
  Future<void> submit(Review review) async {
    await repository.submitReview(review);
    _reviews.add(review);
    _state = Loaded(List.unmodifiable(_reviews));
    notifyListeners();
  }
}
