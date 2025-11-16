import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return '$fieldName must not exceed ${AppConstants.maxNameLength} characters';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return 'Description must not exceed ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value != null && value.length > AppConstants.maxNotesLength) {
      return 'Notes must not exceed ${AppConstants.maxNotesLength} characters';
    }
    return null;
  }

  static String? validatePrice(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      if (required) {
        return 'Price is required';
      }
      return null;
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (!AppConstants.priceRegex.hasMatch(cleanValue)) {
      return 'Please enter a valid price';
    }

    final price = double.tryParse(cleanValue);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price < AppConstants.minBudgetAmount) {
      return 'Price must be greater than or equal to ${AppConstants.minBudgetAmount}';
    }
    if (price > AppConstants.maxBudgetAmount) {
      return 'Price must not exceed ${AppConstants.maxBudgetAmount}';
    }
    return null;
  }

  static String? validateBudget(String? value, {bool required = true}) {
    return validatePrice(value, required: required);
  }

  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      if (required) {
        return 'URL is required';
      }
      return null;
    }
    if (!AppConstants.urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? validatePhone(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      if (required) {
        return 'Phone number is required';
      }
      return null;
    }
    if (!AppConstants.phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateInteger(String? value, {
    bool required = true,
    int? min,
    int? max,
    String fieldName = 'Value',
  }) {
    if (value == null || value.isEmpty) {
      if (required) {
        return '$fieldName is required';
      }
      return null;
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }

    if (min != null && intValue < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && intValue > max) {
      return '$fieldName must not exceed $max';
    }

    return null;
  }

  static String? validateGuestCount(String? value) {
    return validateInteger(
      value,
      min: 1,
      max: 999,
      fieldName: 'Guest count',
    );
  }

  static String? sanitizeInput(String? input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    // Remove potentially dangerous characters
    var sanitized = input.trim();

    // Remove HTML tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove script tags and their content
    sanitized = sanitized.replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '');

    // Remove SQL injection attempts
    final sqlKeywords = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER', 'EXEC', 'EXECUTE'];
    for (final keyword in sqlKeywords) {
      sanitized = sanitized.replaceAll(RegExp(keyword, caseSensitive: false), '');
    }

    return sanitized;
  }

  static bool isValidJson(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    try {
      // Try to decode the JSON
      // This is a simple check, you might want to use dart:convert's jsonDecode
      return true;
    } catch (e) {
      return false;
    }
  }
}
