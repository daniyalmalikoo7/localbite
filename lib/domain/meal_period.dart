/// The meal window a review was written in.
///
/// LocalBite keeps breakfast, lunch and dinner feedback separate rather than
/// averaging them into a single rating that describes neither experience.
enum MealPeriod {
  breakfast('Breakfast', 6 * 60, 11 * 60),
  lunch('Lunch', 11 * 60, 16 * 60),
  dinner('Dinner', 16 * 60, 22 * 60);

  const MealPeriod(this.label, this.startMinute, this.endMinute);

  final String label;
  final int startMinute;
  final int endMinute;

  /// Classifies a timestamp. Returns null outside all three windows (late
  /// night), in which case the review is tagged by the author instead.
  static MealPeriod? at(DateTime time) {
    final minuteOfDay = time.hour * 60 + time.minute;
    for (final period in values) {
      if (minuteOfDay >= period.startMinute && minuteOfDay < period.endMinute) {
        return period;
      }
    }
    return null;
  }
}
