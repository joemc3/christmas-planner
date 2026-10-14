import 'package:christmas_planner/core/domain/statuses.dart';
import 'package:christmas_planner/features/gifts/data/models/gift_model.dart';
import 'package:christmas_planner/features/gifts/data/models/recipient_model.dart';
import 'package:christmas_planner/features/home/presentation/providers/home_data.dart';
import 'package:christmas_planner/features/meals/data/models/meal_item_model.dart';
import 'package:christmas_planner/features/meals/data/models/meal_model.dart';
import 'package:christmas_planner/features/plan/data/models/plan_model.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime(2026, 10, 1);

PlanModel plan({double budget = 600}) => PlanModel(
  id: 'p',
  userId: 'u',
  year: 2026,
  giftBudgetTotal: budget,
  createdAt: _t,
  updatedAt: _t,
);

RecipientModel person(String id, String name, double budget) => RecipientModel(
  id: id,
  planId: 'p',
  name: name,
  budgetLimit: budget,
  createdAt: _t,
  updatedAt: _t,
);

GiftModel gift(
  String id,
  String rid,
  String name,
  double price,
  GiftStatus s,
) => GiftModel(
  id: id,
  recipientId: rid,
  name: name,
  price: price,
  status: s,
  createdAt: _t,
  updatedAt: _t,
);

MealModel meal(String id, MealType type, double budget) => MealModel(
  id: id,
  planId: 'p',
  type: type,
  guestCount: 0,
  budgetLimit: budget,
  createdAt: _t,
  updatedAt: _t,
);

MealItemModel item(String id, String mid, double cost, MealItemStatus s) =>
    MealItemModel(
      id: id,
      mealId: mid,
      itemName: id,
      cost: cost,
      status: s,
      createdAt: _t,
      updatedAt: _t,
    );

void main() {
  final people = [person('mum', 'Mum', 150), person('ellie', 'Ellie', 80)];
  final gifts = [
    gift('g1', 'mum', 'Espresso machine', 129, GiftStatus.ordered),
    gift('g2', 'mum', 'Signed hardback', 24.99, GiftStatus.toBuy),
    gift('g3', 'ellie', 'Watercolour set', 34.5, GiftStatus.toBuy),
    gift('g4', 'ellie', 'The Wild Robot', 14.99, GiftStatus.toBuy),
  ];
  final meals = [
    meal('eve', MealType.xmasEve, 120),
    meal('day', MealType.xmasDay, 220),
  ];
  final items = [
    item('turkey', 'day', 64, MealItemStatus.purchased),
    item('pigs', 'day', 12, MealItemStatus.toBuy),
  ];

  HomeData build({required DateTime today, bool readOnly = false}) =>
      buildHomeData(
        plan: plan(),
        readOnly: readOnly,
        today: today,
        shippingDays: 7,
        recipients: people,
        gifts: gifts,
        meals: meals,
        items: items,
        previousYears: const [],
      );

  test('before the date: countdown and no one needing order', () {
    final d = build(today: DateTime(2026, 10, 14));
    expect(d.startBy, DateTime(2026, 11, 26));
    expect(d.orderingState, HomeOrderingState.before);
    expect(d.daysToStart, 43);
    expect(d.daysToChristmas, 72);
    expect(d.needingOrder, isEmpty);
    expect(d.giftMoney.spent, 129);
    expect(d.giftMoney.remaining, 471);
    expect(d.giftMoney.purchasedCount, 0);
    expect(d.giftMoney.plannedCount, 4);
  });

  test('on the date: three gifts need ordering, by person then name', () {
    final d = build(today: DateTime(2026, 11, 26));
    expect(d.orderingState, HomeOrderingState.needsOrdering);
    expect(d.needingOrder.map((n) => n.gift.name), [
      'The Wild Robot',
      'Watercolour set',
      'Signed hardback',
    ]);
    expect(needingOrderByRecipient(d), {'ellie': 2, 'mum': 1});
  });

  test('after the date with everything handled: all ordered', () {
    final handled = buildHomeData(
      plan: plan(),
      readOnly: false,
      today: DateTime(2026, 11, 28),
      shippingDays: 7,
      recipients: people,
      gifts: [for (final g in gifts) g.copyWith(status: GiftStatus.ordered)],
      meals: meals,
      items: items,
      previousYears: const [],
    );
    expect(handled.orderingState, HomeOrderingState.allOrdered);
    expect(handled.needingOrder, isEmpty);
  });

  test('meal money sums Eve and Day', () {
    final d = build(today: DateTime(2026, 10, 14));
    expect(d.mealMoney.budget, 340);
    expect(d.mealMoney.spent, 64);
    expect(d.mealMoney.remaining, 276);
    expect(d.mealMoney.purchasedCount, 1);
    expect(d.mealMoney.plannedCount, 2);
  });

  test('read-only wins over the date', () {
    final d = build(today: DateTime(2026, 11, 26), readOnly: true);
    expect(d.orderingState, HomeOrderingState.readOnly);
  });

  test('shipping days move the date', () {
    final d = buildHomeData(
      plan: plan(),
      readOnly: false,
      today: DateTime(2026, 10, 14),
      shippingDays: 14,
      recipients: people,
      gifts: gifts,
      meals: meals,
      items: items,
      previousYears: const [],
    );
    expect(d.startBy, DateTime(2026, 11, 19));
  });
}
