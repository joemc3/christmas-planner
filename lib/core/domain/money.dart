/// Budget, planned, spent and remaining. Pure Dart, computed from rows at
/// display time; nothing is stored (PRD section 5).
library;

import 'statuses.dart';

/// What the money functions need to know about a gift.
abstract interface class GiftLike {
  double get price;
  GiftStatus get status;
}

/// What the money functions need to know about a menu item.
abstract interface class MealItemLike {
  double get cost;
  MealItemStatus get status;
}

/// Budget, planned, spent, remaining and the purchased-of-planned counts.
class MoneyTriple {
  const MoneyTriple({
    required this.budget,
    required this.planned,
    required this.spent,
    required this.plannedCount,
    required this.purchasedCount,
  });

  final double budget;

  /// Sum of every price or cost, whatever the status.
  final double planned;

  /// Sum of what counts as spent: Ordered and Purchased gifts, Purchased items.
  final double spent;

  final int plannedCount;
  final int purchasedCount;

  double get remaining => roundMoney(budget - spent);

  bool get isOverBudget => spent > budget;

  /// Planned exceeds budget though spent does not yet (the brass warning).
  bool get isPlannedOver => !isOverBudget && planned > budget;

  double get overBy => isOverBudget ? roundMoney(spent - budget) : 0;

  double get plannedOverBy =>
      planned > budget ? roundMoney(planned - budget) : 0;

  /// Share of the budget used, for the bar. 0 when there is no budget.
  double get fraction =>
      budget <= 0 ? 0 : (spent / budget).clamp(0.0, 1.0).toDouble();

  /// A budget of 0 reads as "not set" (spec section 11).
  bool get hasBudget => budget > 0;

  static const empty = MoneyTriple(
    budget: 0,
    planned: 0,
    spent: 0,
    plannedCount: 0,
    purchasedCount: 0,
  );
}

/// Two-decimal rounding so sums of prices never show 0.30000000000000004.
double roundMoney(double value) => (value * 100).round() / 100;

MoneyTriple giftMoney(Iterable<GiftLike> gifts, {required double budget}) {
  var planned = 0.0;
  var spent = 0.0;
  var count = 0;
  var purchased = 0;
  for (final g in gifts) {
    count++;
    planned += g.price;
    if (g.status.countsAsSpent) spent += g.price;
    if (g.status == GiftStatus.purchased) purchased++;
  }
  return MoneyTriple(
    budget: budget,
    planned: roundMoney(planned),
    spent: roundMoney(spent),
    plannedCount: count,
    purchasedCount: purchased,
  );
}

MoneyTriple mealMoney(Iterable<MealItemLike> items, {required double budget}) {
  var planned = 0.0;
  var spent = 0.0;
  var count = 0;
  var purchased = 0;
  for (final i in items) {
    count++;
    planned += i.cost;
    if (i.status.countsAsSpent) {
      spent += i.cost;
      purchased++;
    }
  }
  return MoneyTriple(
    budget: budget,
    planned: roundMoney(planned),
    spent: roundMoney(spent),
    plannedCount: count,
    purchasedCount: purchased,
  );
}

/// Adds triples, for the master meal view and the Home gift summary.
MoneyTriple sumMoney(Iterable<MoneyTriple> triples) {
  var budget = 0.0;
  var planned = 0.0;
  var spent = 0.0;
  var count = 0;
  var purchased = 0;
  for (final t in triples) {
    budget += t.budget;
    planned += t.planned;
    spent += t.spent;
    count += t.plannedCount;
    purchased += t.purchasedCount;
  }
  return MoneyTriple(
    budget: roundMoney(budget),
    planned: roundMoney(planned),
    spent: roundMoney(spent),
    plannedCount: count,
    purchasedCount: purchased,
  );
}
