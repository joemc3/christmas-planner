import 'package:christmas_planner/core/domain/gift_dates.dart';
import 'package:christmas_planner/core/domain/statuses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 14, 9, 30);
  final day = DateTime(2026, 10, 14);
  final earlier = DateTime(2026, 10, 2);

  test('To Buy to Ordered stamps the order date', () {
    final d = datesAfterStatusChange(
      to: GiftStatus.ordered,
      current: (orderDate: null, purchasedDate: null),
      today: today,
    );
    expect(d.orderDate, day);
    expect(d.purchasedDate, isNull);
  });

  test('Ordered to Purchased stamps the purchase date and keeps the order date', () {
    final d = datesAfterStatusChange(
      to: GiftStatus.purchased,
      current: (orderDate: earlier, purchasedDate: null),
      today: today,
    );
    expect(d.orderDate, earlier);
    expect(d.purchasedDate, day);
  });

  test('skipping Ordered leaves the order date unset', () {
    final d = datesAfterStatusChange(
      to: GiftStatus.purchased,
      current: (orderDate: null, purchasedDate: null),
      today: today,
    );
    expect(d.orderDate, isNull);
    expect(d.purchasedDate, day);
  });

  test('an existing date is never overwritten', () {
    final d = datesAfterStatusChange(
      to: GiftStatus.purchased,
      current: (orderDate: earlier, purchasedDate: earlier),
      today: today,
    );
    expect(d.purchasedDate, earlier);
  });

  test('moving back to Ordered clears the purchase date', () {
    final d = datesAfterStatusChange(
      to: GiftStatus.ordered,
      current: (orderDate: earlier, purchasedDate: day),
      today: today,
    );
    expect(d.orderDate, earlier);
    expect(d.purchasedDate, isNull);
  });

  test('moving back to To Buy clears both', () {
    final d = datesAfterStatusChange(
      to: GiftStatus.toBuy,
      current: (orderDate: earlier, purchasedDate: day),
      today: today,
    );
    expect(d.orderDate, isNull);
    expect(d.purchasedDate, isNull);
  });
}
