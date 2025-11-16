import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Christmas Planner';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Supabase Configuration
  static const String supabaseUrl = kDebugMode
      ? String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'http://localhost:54321',
        )
      : String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = kDebugMode
      ? String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
        )
      : String.fromEnvironment('SUPABASE_ANON_KEY');

  // Date Constants
  static const int christmasMonth = 12;
  static const int christmasDay = 25;
  static const int preparationTargetDay = 10;
  static const int defaultBufferDays = 7;
  static const int defaultShippingDays = 7;

  // Budget Constants
  static const double defaultGiftBudget = 1000.0;
  static const double defaultMealBudget = 500.0;
  static const double minBudgetAmount = 0.0;
  static const double maxBudgetAmount = 999999.99;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Storage Keys
  static const String storageKeyThemeMode = 'theme_mode';
  static const String storageKeyLanguage = 'language';
  static const String storageKeyOnboardingComplete = 'onboarding_complete';
  static const String storageKeyLastSyncTime = 'last_sync_time';

  // Validation
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 1000;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // URLs
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmail = 'support@christmasplanner.app';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce Durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration autoSaveDebounce = Duration(seconds: 2);

  // Cache Durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);

  // Gift Status
  static const String giftStatusToBuy = 'To Buy';
  static const String giftStatusOrdered = 'Ordered';
  static const String giftStatusPurchased = 'Purchased';
  static const String giftStatusWrapped = 'Wrapped';
  static const String giftStatusDelivered = 'Delivered';

  // Meal Item Status
  static const String mealItemStatusToBuy = 'To Buy';
  static const String mealItemStatusPurchased = 'Purchased';
  static const String mealItemStatusPrepared = 'Prepared';

  // Meal Types
  static const String mealTypeXmasEve = 'Xmas_Eve';
  static const String mealTypeXmasDay = 'Xmas_Day';
  static const String mealTypeOther = 'Other';

  // Categories
  static const List<String> giftCategories = [
    'Toys',
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
    'Sports & Outdoors',
    'Beauty & Personal Care',
    'Food & Beverages',
    'Gift Cards',
    'Other',
  ];

  static const List<String> mealCategories = [
    'Main Course',
    'Side Dish',
    'Appetizer',
    'Dessert',
    'Beverage',
    'Condiment',
    'Other',
  ];

  static const List<String> ageGroups = [
    'Baby (0-2)',
    'Toddler (3-5)',
    'Child (6-12)',
    'Teen (13-17)',
    'Adult (18-64)',
    'Senior (65+)',
  ];

  static const List<String> relationships = [
    'Parent',
    'Child',
    'Sibling',
    'Spouse',
    'Partner',
    'Grandparent',
    'Grandchild',
    'Aunt/Uncle',
    'Niece/Nephew',
    'Cousin',
    'Friend',
    'Colleague',
    'Other',
  ];

  static const List<String> priorities = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'PayPal',
    'Venmo',
    'Gift Card',
    'Other',
  ];

  static const List<String> dietaryRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut Allergy',
    'Kosher',
    'Halal',
    'Low-Carb',
    'Keto',
    'Paleo',
  ];

  // Notification Types
  static const String notificationTypeReminder = 'reminder';
  static const String notificationTypeBudgetAlert = 'budget_alert';
  static const String notificationTypeDeadline = 'deadline';
  static const String notificationTypeDelivery = 'delivery';
  static const String notificationTypeGeneral = 'general';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorUnauthorized = 'Unauthorized. Please sign in again.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation = 'Please check your input and try again.';
  static const String errorTimeout = 'Request timed out. Please try again.';

  // Success Messages
  static const String successSaved = 'Successfully saved!';
  static const String successDeleted = 'Successfully deleted!';
  static const String successUpdated = 'Successfully updated!';
  static const String successCreated = 'Successfully created!';

  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[\d\s\-\(\)]+$',
  );
  static final RegExp priceRegex = RegExp(
    r'^\d+(\.\d{1,2})?$',
  );
}
