import 'package:intl/intl.dart';

/// Currencies offered in Settings, code to display name.
const Map<String, String> currencies = {
  'USD': 'US dollar (\$)',
  'GBP': 'British pound (£)',
  'EUR': 'Euro (€)',
  'CAD': 'Canadian dollar (\$)',
  'AUD': 'Australian dollar (\$)',
  'NZD': 'New Zealand dollar (\$)',
};

/// "$153.99", always two decimals, in the given ISO currency code.
String formatMoney(double amount, {String currency = 'USD'}) =>
    NumberFormat.simpleCurrency(
      name: currency,
      decimalDigits: 2,
    ).format(amount);

/// The symbol alone, for input prefixes.
String currencySymbol(String currency) =>
    NumberFormat.simpleCurrency(name: currency).currencySymbol;

/// Parses user-entered money like "1,299.99" or "$40" to a double.
double parseMoney(String? value) {
  if (value == null) return 0;
  final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
  return double.tryParse(cleaned) ?? 0;
}

/// "26 November"
String formatDayMonth(DateTime d) => DateFormat('d MMMM').format(d);

/// "2 Oct"
String formatShortDate(DateTime d) => DateFormat('d MMM').format(d);

/// "Friday 2 October 2026"
String formatLongDate(DateTime d) => DateFormat('EEEE d MMMM y').format(d);

/// "26 November 2026"
String formatDayMonthYear(DateTime d) => DateFormat('d MMMM y').format(d);
