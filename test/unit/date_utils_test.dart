import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_planner/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    test('formatCurrency should format correctly', () {
      expect(AppDateUtils.formatCurrency(100.5), '\$ 100.50');
      expect(AppDateUtils.formatCurrency(0), '\$ 0.00');
    });

    test('formatDate should format correctly', () {
      final date = DateTime(2025, 12, 25);
      expect(AppDateUtils.formatDate(date), 'Dec 25, 2025');
    });

    test('isSameDay should compare dates correctly', () {
      final date1 = DateTime(2025, 12, 25, 10, 30);
      final date2 = DateTime(2025, 12, 25, 14, 45);
      final date3 = DateTime(2025, 12, 26);

      expect(AppDateUtils.isSameDay(date1, date2), true);
      expect(AppDateUtils.isSameDay(date1, date3), false);
    });

    test('isOverdue should detect overdue dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));

      expect(AppDateUtils.isOverdue(pastDate), true);
      expect(AppDateUtils.isOverdue(futureDate), false);
    });
  });
}
