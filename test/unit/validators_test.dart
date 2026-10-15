import 'package:christmas_planner/core/utils/format.dart';
import 'package:christmas_planner/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    test('accepts a valid email', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });
    test('rejects junk, empty and null', () {
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });
  });

  group('validatePassword', () {
    test('needs eight characters and nothing else', () {
      expect(Validators.validatePassword('mistletoe'), isNull);
      expect(Validators.validatePassword('Password123!'), isNull);
      expect(Validators.validatePassword('short'), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });
  });

  group('validateConfirmPassword', () {
    test('must match', () {
      expect(
        Validators.validateConfirmPassword('abcdefgh', 'abcdefgh'),
        isNull,
      );
      expect(
        Validators.validateConfirmPassword('abcdefgh', 'other'),
        isNotNull,
      );
      expect(Validators.validateConfirmPassword('', 'x'), isNotNull);
    });
  });

  group('validateName', () {
    test('required and bounded', () {
      expect(Validators.validateName('Mum'), isNull);
      expect(Validators.validateName('   '), isNotNull);
      expect(Validators.validateName('x' * 101), isNotNull);
    });
  });

  group('validatePrice', () {
    test('accepts plain and formatted amounts', () {
      expect(Validators.validatePrice('100.50'), isNull);
      expect(Validators.validatePrice(r'$1,299.99'), isNull);
      expect(Validators.validatePrice('0'), isNull);
    });
    test('accepts a leading or trailing decimal point, like parseMoney', () {
      expect(Validators.validatePrice('.50'), isNull);
      expect(parseMoney('.50'), 0.5);
      expect(Validators.validatePrice('1.'), isNull);
      expect(parseMoney('1.'), 1.0);
      expect(Validators.validatePrice('.'), isNotNull);
    });
    test('rejects junk, negatives and three decimals', () {
      expect(Validators.validatePrice('abc'), isNotNull);
      expect(Validators.validatePrice('-10'), isNotNull);
      expect(Validators.validatePrice('1.999'), isNotNull);
    });
    test('optional when empty', () {
      expect(Validators.validatePrice('', required: false), isNull);
      expect(Validators.validatePrice(''), isNotNull);
    });
  });

  group('validateInteger', () {
    test('bounds', () {
      expect(Validators.validateInteger('7', min: 0, max: 60), isNull);
      expect(Validators.validateInteger('61', min: 0, max: 60), isNotNull);
      expect(Validators.validateInteger('x'), isNotNull);
    });
  });

  group('sanitizeInput', () {
    test('removes HTML tags and script content, keeps text', () {
      expect(
        Validators.sanitizeInput('<script>alert("xss")</script>Hello'),
        'Hello',
      );
      expect(
        Validators.sanitizeInput('Select a gift to update'),
        'Select a gift to update',
      );
      expect(Validators.sanitizeInput('  Hello  '), 'Hello');
    });
  });
}
