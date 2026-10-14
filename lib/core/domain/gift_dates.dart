/// Which dates a status change stamps or clears (spec section 11).
library;

import 'statuses.dart';

typedef GiftDates = ({DateTime? orderDate, DateTime? purchasedDate});

/// Moving to Ordered stamps the order date if it is unset. Moving to
/// Purchased stamps the purchase date if unset; skipping Ordered leaves the
/// order date unset. Moving back clears the dates of states no longer
/// reached. Dates already set are never overwritten.
GiftDates datesAfterStatusChange({
  required GiftStatus to,
  required GiftDates current,
  required DateTime today,
}) {
  final day = DateTime(today.year, today.month, today.day);
  switch (to) {
    case GiftStatus.toBuy:
      return (orderDate: null, purchasedDate: null);
    case GiftStatus.ordered:
      return (orderDate: current.orderDate ?? day, purchasedDate: null);
    case GiftStatus.purchased:
      return (
        orderDate: current.orderDate,
        purchasedDate: current.purchasedDate ?? day,
      );
  }
}
