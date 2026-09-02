/// Food types a vendor can be filtered by.
enum FoodCategory {
  asian('Asian', '🍜'),
  mexican('Mexican', '🌮'),
  burgers('Burgers', '🍔'),
  indian('Indian', '🍛'),
  middleEastern('Middle Eastern', '🌯'),
  bakery('Bakery', '🥐'),
  coffee('Coffee', '☕'),
  dessert('Dessert', '🍦'),
  seafood('Seafood', '🦐'),
  drinks('Drinks', '🧋');

  const FoodCategory(this.label, this.emoji);

  final String label;
  final String emoji;

  /// The four surfaced directly on the Home chip row. The rest are reachable
  /// through "More +", which opens the Search & Filter screen.
  static const homeRow = <FoodCategory>[asian, mexican, burgers, indian];
}
