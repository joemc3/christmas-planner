import 'package:flutter_test/flutter_test.dart';
import 'package:christmas_planner/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail('invalid-email'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
      });

      test('should return error for null email', () {
        expect(Validators.validateEmail(null), isNotNull);
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('Password123!'), null);
      });

      test('should return error for password without uppercase', () {
        expect(Validators.validatePassword('password123!'), isNotNull);
      });

      test('should return error for password without lowercase', () {
        expect(Validators.validatePassword('PASSWORD123!'), isNotNull);
      });

      test('should return error for password without number', () {
        expect(Validators.validatePassword('Password!'), isNotNull);
      });

      test('should return error for password without special character', () {
        expect(Validators.validatePassword('Password123'), isNotNull);
      });

      test('should return error for short password', () {
        expect(Validators.validatePassword('Pass1!'), isNotNull);
      });
    });

    group('validatePrice', () {
      test('should return null for valid price', () {
        expect(Validators.validatePrice('100.50'), null);
      });

      test('should return error for invalid price', () {
        expect(Validators.validatePrice('abc'), isNotNull);
      });

      test('should return error for negative price', () {
        expect(Validators.validatePrice('-10'), isNotNull);
      });

      test('should return null for optional empty price', () {
        expect(Validators.validatePrice('', required: false), null);
      });
    });

    group('sanitizeInput', () {
      test('should remove HTML tags', () {
        expect(
          Validators.sanitizeInput('<script>alert("xss")</script>Hello'),
          'Hello',
        );
      });

      test('should remove SQL keywords', () {
        final result = Validators.sanitizeInput('SELECT * FROM users');
        expect(result, isNot(contains('SELECT')));
      });

      test('should trim whitespace', () {
        expect(Validators.sanitizeInput('  Hello  '), 'Hello');
      });
    });
  });
}
