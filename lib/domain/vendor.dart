import 'package:flutter/foundation.dart';

import 'food_category.dart';
import 'geo_point.dart';
import 'opening_hours.dart';
import 'vendor_status.dart';

/// An independent street-food stall.
@immutable
class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.primaryCategory,
    required this.cuisineLabel,
    required this.suburb,
    required this.emoji,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.hours,
    required this.baseQueueMinutes,
    required this.lastUpdatedAt,
    this.tags = const <FoodCategory>{},
    this.blurb = '',
  });

  final String id;
  final String name;
  final FoodCategory primaryCategory;

  /// Display line under the name, e.g. "Middle Eastern · Street Food".
  final String cuisineLabel;
  final String suburb;
  final String emoji;
  final GeoPoint location;
  final double rating;
  final int reviewCount;
  final OpeningHours hours;

  /// Typical queue length in minutes, before the time-of-day adjustment.
  final int baseQueueMinutes;

  /// When the vendor last updated their own listing. Backs the "Recent" sort
  /// and the vendor-managed premise: hours come from the operator, not a register.
  final DateTime lastUpdatedAt;

  final Set<FoodCategory> tags;
  final String blurb;

  Set<FoodCategory> get allCategories => {primaryCategory, ...tags};

  double distanceFrom(GeoPoint origin) => location.distanceTo(origin);

  VendorStatus statusAt(DateTime now) => hours.statusAt(now);

  @override
  bool operator ==(Object other) => other is Vendor && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
