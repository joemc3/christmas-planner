import 'package:christmas_planner/shared/widgets/form_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseMoney', () {
    test('parses plain numbers', () {
      expect(parseMoney('40'), 40);
      expect(parseMoney('12.5'), 12.5);
    });

    test('ignores currency symbols and thousands separators', () {
      expect(parseMoney(r'$1,299.99'), 1299.99);
      expect(parseMoney('€ 80'), 80);
    });

    test('falls back to zero for empty or junk input', () {
      expect(parseMoney(null), 0);
      expect(parseMoney(''), 0);
      expect(parseMoney('abc'), 0);
    });
  });
}
