/// The three enums the product is built on. They live here, not in the
/// feature models, so the domain functions in this folder stay free of
/// Flutter and Supabase imports.
library;

enum GiftStatus {
  toBuy('To Buy'),
  ordered('Ordered'),
  purchased('Purchased');

  const GiftStatus(this.value);

  /// The value stored in Postgres (`gift_status` enum).
  final String value;

  static GiftStatus fromString(String value) => GiftStatus.values.firstWhere(
    (s) => s.value == value,
    orElse: () => GiftStatus.toBuy,
  );

  /// Ordered and Purchased count as spent (PRD section 5).
  bool get countsAsSpent => this != GiftStatus.toBuy;

  bool isAfter(GiftStatus other) => index > other.index;
}

enum MealItemStatus {
  toBuy('To Buy'),
  purchased('Purchased');

  const MealItemStatus(this.value);
  final String value;

  static MealItemStatus fromString(String value) => MealItemStatus.values
      .firstWhere((s) => s.value == value, orElse: () => MealItemStatus.toBuy);

  bool get countsAsSpent => this == MealItemStatus.purchased;
}

enum MealType {
  xmasEve('Xmas_Eve', 'Christmas Eve', 24),
  xmasDay('Xmas_Day', 'Christmas Day', 25);

  const MealType(this.value, this.displayName, this.dayOfDecember);

  final String value;
  final String displayName;

  /// The calendar day in December the meal falls on, derived for display
  /// and never stored (spec section 11).
  final int dayOfDecember;

  static MealType fromString(String value) => MealType.values.firstWhere(
    (t) => t.value == value,
    orElse: () => MealType.xmasDay,
  );

  DateTime dateIn(int year) => DateTime(year, 12, dayOfDecember);
}
