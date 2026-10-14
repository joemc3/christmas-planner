import 'package:christmas_planner/core/domain/money.dart';
import 'package:christmas_planner/core/domain/statuses.dart';
import 'package:flutter_test/flutter_test.dart';

class _Gift implements GiftLike {
  _Gift(this.price, this.status);
  @override
  final double price;
  @override
  final GiftStatus status;
}

class _Item implements MealItemLike {
  _Item(this.cost, this.status);
  @override
  final double cost;
  @override
  final MealItemStatus status;
}

void main() {
  group('giftMoney', () {
    test('empty list is all zero and not over budget', () {
      final m = giftMoney(const [], budget: 150);
      expect(m.planned, 0);
      expect(m.spent, 0);
      expect(m.remaining, 150);
      expect(m.plannedCount, 0);
      expect(m.purchasedCount, 0);
      expect(m.isOverBudget, false);
      expect(m.fraction, 0);
    });

    test('spent counts Ordered and Purchased, planned counts everything', () {
      final m = giftMoney([
        _Gift(129, GiftStatus.ordered),
        _Gift(24.99, GiftStatus.toBuy),
        _Gift(10, GiftStatus.purchased),
      ], budget: 150);
      expect(m.planned, 163.99);
      expect(m.spent, 139);
      expect(m.remaining, 11);
      expect(m.plannedCount, 3);
      expect(m.purchasedCount, 1);
    });

    test('the brief example: Mum planned over, not spent over', () {
      final m = giftMoney([
        _Gift(129, GiftStatus.ordered),
        _Gift(24.99, GiftStatus.toBuy),
      ], budget: 150);
      expect(m.remaining, 21);
      expect(m.isOverBudget, false);
      expect(m.isPlannedOver, true);
      expect(m.plannedOverBy, 3.99);
    });

    test('spent over budget', () {
      final m = giftMoney([_Gift(112, GiftStatus.purchased)], budget: 100);
      expect(m.isOverBudget, true);
      expect(m.overBy, 12);
      expect(m.remaining, -12);
      expect(m.fraction, 1);
      expect(m.isPlannedOver, false);
    });

    test('rounds to two decimals', () {
      final m = giftMoney([
        _Gift(0.1, GiftStatus.purchased),
        _Gift(0.2, GiftStatus.purchased),
      ], budget: 1);
      expect(m.spent, 0.3);
      expect(m.remaining, 0.7);
    });

    test('budget 0 reads as unset', () {
      expect(giftMoney(const [], budget: 0).hasBudget, false);
      expect(giftMoney(const [], budget: 1).hasBudget, true);
    });
  });

  group('mealMoney', () {
    test('spent counts Purchased only', () {
      final m = mealMoney([
        _Item(64, MealItemStatus.purchased),
        _Item(12, MealItemStatus.toBuy),
        _Item(18.5, MealItemStatus.purchased),
        _Item(14, MealItemStatus.toBuy),
      ], budget: 220);
      expect(m.planned, 108.5);
      expect(m.spent, 82.5);
      expect(m.remaining, 137.5);
      expect(m.plannedCount, 4);
      expect(m.purchasedCount, 2);
    });
  });

  group('sumMoney', () {
    test('adds the two meals for the master meal view', () {
      final eve = mealMoney([
        _Item(28.5, MealItemStatus.purchased),
      ], budget: 120);
      final day = mealMoney([
        _Item(82.5, MealItemStatus.purchased),
      ], budget: 220);
      final total = sumMoney([eve, day]);
      expect(total.budget, 340);
      expect(total.spent, 111);
      expect(total.remaining, 229);
      expect(total.purchasedCount, 2);
    });
  });
}
