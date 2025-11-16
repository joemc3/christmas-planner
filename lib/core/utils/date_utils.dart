import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppDateUtils {
  AppDateUtils._();

  static DateTime get now => DateTime.now();

  static DateTime get christmasEve {
    final year = now.year;
    return DateTime(year, AppConstants.christmasMonth, 24);
  }

  static DateTime get christmasDay {
    final year = now.year;
    return DateTime(year, AppConstants.christmasMonth, AppConstants.christmasDay);
  }

  static DateTime get preparationTargetDate {
    final year = now.year;
    return DateTime(year, AppConstants.christmasMonth, AppConstants.preparationTargetDay);
  }

  static DateTime calculateStartOrderingDate({int? customShippingDays}) {
    final shippingDays = customShippingDays ?? AppConstants.defaultShippingDays;
    final totalDays = AppConstants.defaultBufferDays + shippingDays;
    return preparationTargetDate.subtract(Duration(days: totalDays));
  }

  static int daysUntilChristmas() {
    final christmas = christmasDay;
    final today = DateTime.now();
    final difference = christmas.difference(today);
    return difference.inDays;
  }

  static int daysUntilPreparationDeadline() {
    final deadline = preparationTargetDate;
    final today = DateTime.now();
    final difference = deadline.difference(today);
    return difference.inDays;
  }

  static bool isBeforeChristmas() {
    return now.isBefore(christmasDay);
  }

  static bool isBeforePreparationDeadline() {
    return now.isBefore(preparationTargetDate);
  }

  static String formatDate(DateTime? date, {String format = 'MMM dd, yyyy'}) {
    if (date == null) return '';
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime? time) {
    if (time == null) return '';
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  static String formatRelativeDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays > 1 && difference.inDays <= 7) {
      return 'In ${difference.inDays} days';
    } else if (difference.inDays < -1 && difference.inDays >= -7) {
      return '${difference.inDays.abs()} days ago';
    } else {
      return formatDate(date);
    }
  }

  static String formatCurrency(double? amount, {String symbol = '\$'}) {
    if (amount == null) return '$symbol 0.00';
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final start = startOfMonth(date);
    final end = endOfMonth(date);
    final days = <DateTime>[];

    for (var day = start; day.isBefore(end) || day.isAtSameMomentAs(end); day = day.add(const Duration(days: 1))) {
      days.add(day);
    }

    return days;
  }

  static String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return now.isAfter(dueDate);
  }

  static int getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(startOfYear).inDays;
    return ((days + startOfYear.weekday) / 7).ceil();
  }

  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }
}
