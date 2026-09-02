import 'package:flutter/foundation.dart';

import 'meal_period.dart';

/// A single review, tagged with the meal window it was written in.
@immutable
class Review {
  const Review({
    required this.id,
    required this.vendorId,
    required this.authorName,
    required this.authorEmoji,
    required this.rating,
    required this.body,
    required this.postedAt,
    required this.mealPeriod,
  });

  final String id;
  final String vendorId;
  final String authorName;
  final String authorEmoji;

  /// Whole stars, 1–5.
  final int rating;
  final String body;
  final DateTime postedAt;

  /// Captured when the review is written, not chosen by the reader. A user
  /// browsing dinner options sees dinner feedback without touching a filter.
  final MealPeriod mealPeriod;

  @override
  bool operator ==(Object other) => other is Review && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
