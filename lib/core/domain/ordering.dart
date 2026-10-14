/// Start Ordering By and the state of each gift against it. Pure Dart; the
/// rules are PRD 1.1 sections 4.3 and 5.
library;

import 'statuses.dart';

/// 10 December: everything must be in the house by this day.
const int preparationDay = 10;

/// Days for wrapping, final preparation and contingency.
const int bufferDays = 7;

const int minShippingDays = 0;
const int maxShippingDays = 60;
const int defaultShippingDays = 7;

DateTime preparationTarget(int year) => DateTime(year, 12, preparationDay);

DateTime christmas(int year) => DateTime(year, 12, 25);

int clampShippingDays(int days) => days.clamp(minShippingDays, maxShippingDays);

/// 10 December minus (buffer plus the user's shipping days). With the
/// default 7 shipping days this is 26 November.
///
/// Calendar-day arithmetic, not a Duration: subtracting hours across the
/// daylight-saving change would land an hour off midnight.
DateTime startOrderingBy(int year, int shippingDays) => DateTime(
  year,
  12,
  preparationDay - bufferDays - clampShippingDays(shippingDays),
);

/// Midnight of the given moment, so day arithmetic ignores the time.
DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

/// Whole days from [today] to [target]; negative when the target has passed.
/// Compared in UTC so a daylight-saving change never yields a 23-hour day.
int daysUntil(DateTime target, DateTime today) => DateTime.utc(
  target.year,
  target.month,
  target.day,
).difference(DateTime.utc(today.year, today.month, today.day)).inDays;

enum OrderingState {
  /// Still To Buy and the ordering date is in the future.
  notYet,

  /// Still To Buy and today is the ordering date.
  dueToday,

  /// Still To Buy and the ordering date has passed.
  overdue,

  /// Ordered or Purchased: the date no longer applies.
  handled,
}

OrderingState giftOrderingState({
  required GiftStatus status,
  required DateTime today,
  required DateTime startBy,
}) {
  if (status.countsAsSpent) return OrderingState.handled;
  final days = daysUntil(startBy, today);
  if (days > 0) return OrderingState.notYet;
  if (days == 0) return OrderingState.dueToday;
  return OrderingState.overdue;
}

/// A gift needs ordering now when it is To Buy and today is on or after
/// Start Ordering By (PRD section 5).
bool giftNeedsOrderingNow({
  required GiftStatus status,
  required DateTime today,
  required DateTime startBy,
}) {
  final state = giftOrderingState(
    status: status,
    today: today,
    startBy: startBy,
  );
  return state == OrderingState.dueToday || state == OrderingState.overdue;
}

int countNeedingOrder(
  Iterable<GiftStatus> statuses, {
  required DateTime today,
  required DateTime startBy,
}) => statuses
    .where(
      (s) => giftNeedsOrderingNow(status: s, today: today, startBy: startBy),
    )
    .length;
