import 'meal_period.dart';
import 'vendor.dart';

/// Estimated wait at the stall, in minutes.
///
/// Derived rather than stored. The value is a pure function of the vendor and
/// a five-minute time bucket, so it holds steady while someone reads the
/// screen but visibly moves over the course of a demo — and it is reproducible
/// in tests. Queues also lengthen inside a meal window.
int estimatedWaitMinutes(Vendor vendor, DateTime now) {
  const bucketMillis = 5 * 60 * 1000;
  final bucket = now.millisecondsSinceEpoch ~/ bucketMillis;
  final jitter = Object.hash(vendor.id, bucket).abs() % 7 - 3;
  final mealTimeSurge = MealPeriod.at(now) == null ? 0 : 4;
  return (vendor.baseQueueMinutes + jitter + mealTimeSurge).clamp(1, 45);
}

/// How full the queue meter reads, 0–1. Thirty minutes is treated as a full bar.
double queueFraction(int waitMinutes) => (waitMinutes / 30).clamp(0.05, 1.0);
