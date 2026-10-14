import 'package:christmas_planner/core/domain/ordering.dart';
import 'package:christmas_planner/core/domain/statuses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('startOrderingBy', () {
    test('PRD example: 2026 with 7 shipping days is 26 November 2026', () {
      expect(startOrderingBy(2026, 7), DateTime(2026, 11, 26));
    });

    test('0 shipping days leaves only the buffer: 3 December', () {
      expect(startOrderingBy(2026, 0), DateTime(2026, 12, 3));
    });

    test('60 shipping days: 4 October', () {
      expect(startOrderingBy(2026, 60), DateTime(2026, 10, 4));
    });

    test('shipping days are clamped to 0..60', () {
      expect(startOrderingBy(2026, -5), startOrderingBy(2026, 0));
      expect(startOrderingBy(2026, 99), startOrderingBy(2026, 60));
    });

    test('follows the plan year', () {
      expect(startOrderingBy(2027, 7), DateTime(2027, 11, 26));
    });
  });

  group('daysUntil', () {
    test('ignores the time of day', () {
      expect(
        daysUntil(DateTime(2026, 11, 26), DateTime(2026, 11, 25, 23, 59)),
        1,
      );
      expect(daysUntil(DateTime(2026, 11, 26), DateTime(2026, 11, 26, 9)), 0);
      expect(daysUntil(DateTime(2026, 11, 26), DateTime(2026, 11, 27, 1)), -1);
    });
  });

  group('giftOrderingState', () {
    final startBy = DateTime(2026, 11, 26);

    test('notYet the day before', () {
      expect(
        giftOrderingState(
          status: GiftStatus.toBuy,
          today: DateTime(2026, 11, 25),
          startBy: startBy,
        ),
        OrderingState.notYet,
      );
    });

    test('dueToday on the day', () {
      expect(
        giftOrderingState(
          status: GiftStatus.toBuy,
          today: DateTime(2026, 11, 26, 15),
          startBy: startBy,
        ),
        OrderingState.dueToday,
      );
    });

    test('overdue after', () {
      expect(
        giftOrderingState(
          status: GiftStatus.toBuy,
          today: DateTime(2026, 12, 1),
          startBy: startBy,
        ),
        OrderingState.overdue,
      );
    });

    test('handled for Ordered and Purchased regardless of the date', () {
      for (final status in [GiftStatus.ordered, GiftStatus.purchased]) {
        for (final today in [DateTime(2026, 10, 1), DateTime(2026, 12, 20)]) {
          expect(
            giftOrderingState(status: status, today: today, startBy: startBy),
            OrderingState.handled,
          );
        }
      }
    });
  });

  group('countNeedingOrder', () {
    test('counts only To Buy on or after the date', () {
      final startBy = DateTime(2026, 11, 26);
      final statuses = [
        GiftStatus.toBuy,
        GiftStatus.toBuy,
        GiftStatus.ordered,
        GiftStatus.purchased,
      ];
      expect(
        countNeedingOrder(
          statuses,
          today: DateTime(2026, 11, 25),
          startBy: startBy,
        ),
        0,
      );
      expect(
        countNeedingOrder(
          statuses,
          today: DateTime(2026, 11, 26),
          startBy: startBy,
        ),
        2,
      );
    });
  });
}
