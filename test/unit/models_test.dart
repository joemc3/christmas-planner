import 'package:christmas_planner/core/domain/statuses.dart';
import 'package:christmas_planner/features/gifts/data/models/gift_model.dart';
import 'package:christmas_planner/features/gifts/data/models/recipient_model.dart';
import 'package:christmas_planner/features/meals/data/models/meal_item_model.dart';
import 'package:christmas_planner/features/meals/data/models/meal_model.dart';
import 'package:christmas_planner/features/plan/data/models/plan_model.dart';
import 'package:christmas_planner/shared/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

const _ts = '2026-10-14T10:00:00.000Z';

void main() {
  group('PlanModel', () {
    test('round trip', () {
      final p = PlanModel.fromJson(const {
        'id': 'p1',
        'user_id': 'u1',
        'year': 2026,
        'gift_budget_total': 600,
        'created_at': _ts,
        'updated_at': _ts,
      });
      expect(p.year, 2026);
      expect(p.giftBudgetTotal, 600.0);
      expect(p.copyWith(giftBudgetTotal: 650).giftBudgetTotal, 650);
    });
  });

  group('RecipientModel', () {
    test('fromJson and toInsertJson carry only the PRD fields', () {
      final r = RecipientModel.fromJson(const {
        'id': 'r1',
        'plan_id': 'p1',
        'name': 'Mum',
        'budget_limit': 150,
        'created_at': _ts,
        'updated_at': _ts,
      });
      expect(r.initial, 'M');
      expect(r.toInsertJson(), {
        'plan_id': 'p1',
        'name': 'Mum',
        'budget_limit': 150.0,
      });
    });
  });

  group('GiftModel', () {
    final base = GiftModel.fromJson(const {
      'id': 'g1',
      'recipient_id': 'r1',
      'name': 'Espresso machine',
      'price': 129,
      'status': 'To Buy',
      'store_name': null,
      'order_link': 'https://www.johnlewis.com/x',
      'order_date': null,
      'purchased_date': null,
      'created_at': _ts,
      'updated_at': _ts,
    });

    test('dates are written as DATE columns', () {
      final g = base.copyWith(orderDate: DateTime(2026, 10, 2));
      expect(g.toInsertJson()['order_date'], '2026-10-02');
      expect(g.toInsertJson()['purchased_date'], isNull);
    });

    test('DATE columns parse back', () {
      final g = GiftModel.fromJson({
        ...base.toInsertJson(),
        'id': 'g1',
        'order_date': '2026-10-02',
        'purchased_date': '2026-10-05',
        'created_at': _ts,
        'updated_at': _ts,
      });
      expect(g.orderDate, DateTime(2026, 10, 2));
      expect(g.purchasedDate, DateTime(2026, 10, 5));
    });

    test('withStatus stamps and clears per the rules', () {
      final today = DateTime(2026, 10, 14, 12);
      final ordered = base.withStatus(GiftStatus.ordered, today: today);
      expect(ordered.orderDate, DateTime(2026, 10, 14));
      final purchased = ordered.withStatus(GiftStatus.purchased, today: today);
      expect(purchased.orderDate, DateTime(2026, 10, 14));
      expect(purchased.purchasedDate, DateTime(2026, 10, 14));
      final back = purchased.withStatus(GiftStatus.toBuy, today: today);
      expect(back.orderDate, isNull);
      expect(back.purchasedDate, isNull);
    });

    test('storeLabel falls back to the link host', () {
      expect(base.storeLabel, 'www.johnlewis.com');
      expect(base.copyWith(storeName: 'John Lewis').storeLabel, 'John Lewis');
    });

    test('unknown status strings fall back to To Buy', () {
      expect(GiftStatus.fromString('Wrapped'), GiftStatus.toBuy);
    });
  });

  group('MealModel', () {
    test('type gives the name and the date; zero means unset', () {
      final m = MealModel.fromJson(const {
        'id': 'm1',
        'plan_id': 'p1',
        'type': 'Xmas_Day',
        'guest_count': 0,
        'budget_limit': 0,
        'created_at': _ts,
        'updated_at': _ts,
      });
      expect(m.name, 'Christmas Day');
      expect(m.type.dateIn(2026), DateTime(2026, 12, 25));
      expect(m.hasGuests, false);
      expect(m.hasBudget, false);
      expect(m.copyWith(guestCount: 8, budgetLimit: 220).toUpdateJson(), {
        'guest_count': 8,
        'budget_limit': 220.0,
      });
    });
  });

  group('MealItemModel', () {
    test('round trip', () {
      final i = MealItemModel.fromJson(const {
        'id': 'i1',
        'meal_id': 'm1',
        'item_name': 'Turkey crown',
        'cost': 64,
        'status': 'Purchased',
        'created_at': _ts,
        'updated_at': _ts,
      });
      expect(i.status, MealItemStatus.purchased);
      expect(i.toInsertJson(), {
        'meal_id': 'm1',
        'item_name': 'Turkey crown',
        'cost': 64.0,
        'status': 'Purchased',
      });
    });
  });

  group('UserProfile', () {
    test('shipping days are clamped on read and write', () {
      final p = UserProfile.fromJson(const {
        'id': 'u1',
        'email': 'jo@example.com',
        'full_name': 'Jo',
        'currency': 'USD',
        'default_shipping_days': 99,
        'created_at': _ts,
        'updated_at': _ts,
      });
      expect(p.defaultShippingDays, 60);
      expect(
        p
            .copyWith(defaultShippingDays: -1)
            .toUpdateJson()['default_shipping_days'],
        0,
      );
    });
  });
}
