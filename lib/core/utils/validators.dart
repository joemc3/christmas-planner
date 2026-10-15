import '../constants/app_constants.dart';

/// Form validators. Messages are one short line each.
class Validators {
  Validators._();

  static final RegExp _email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static const double maxAmount = 999999.99;

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email';
    if (!_email.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  /// At least 8 characters (PRD ACC-1; the design's hint says exactly that).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter a password';
    if (value.length < AppConstants.minPasswordLength) {
      return 'At least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'Enter the password again';
    if (value != password) return 'The passwords do not match';
    return null;
  }

  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a ${fieldName.toLowerCase()}';
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return '$fieldName must be ${AppConstants.maxNameLength} characters or fewer';
    }
    return null;
  }

  /// Accepts "40", "12.5", ".50", "1.", "$1,299.99": whatever `parseMoney`
  /// reads, to two decimals. Rejects negatives and junk.
  static String? validatePrice(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Enter an amount' : null;
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('-')) return 'Cannot be negative';
    final cleaned = trimmed.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleaned);
    final wellFormed = RegExp(r'^(\d+(\.\d{0,2})?|\.\d{1,2})$');
    if (amount == null || !wellFormed.hasMatch(cleaned)) {
      return 'Enter a valid amount';
    }
    if (amount > maxAmount) return 'Too large';
    return null;
  }

  static String? validateBudget(String? value, {bool required = true}) =>
      validatePrice(value, required: required);

  static String? validateInteger(
    String? value, {
    bool required = true,
    int? min,
    int? max,
    String fieldName = 'Value',
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    final n = int.tryParse(value);
    if (n == null) return 'Enter a whole number';
    if (min != null && n < min) return '$fieldName must be at least $min';
    if (max != null && n > max) return '$fieldName must be $max or fewer';
    return null;
  }

  /// Strips HTML, including script blocks and their content, and trims.
  static String? sanitizeInput(String? input) {
    if (input == null || input.isEmpty) return input;
    var s = input.trim();
    s = s.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
      '',
    );
    s = s.replaceAll(RegExp(r'<[^>]*>'), '');
    return s.trim();
  }
}
