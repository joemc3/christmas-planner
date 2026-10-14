import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/money.dart';
import '../../../../core/domain/ordering.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gifts/data/models/gift_model.dart';
import '../../../gifts/data/models/recipient_model.dart';
import '../../../gifts/presentation/providers/gift_providers.dart';
import '../../../meals/data/models/meal_item_model.dart';
import '../../../meals/data/models/meal_model.dart';
import '../../../meals/presentation/providers/meal_providers.dart';
import '../../../plan/data/models/plan_model.dart';
import '../../../plan/presentation/providers/plan_providers.dart';

/// What the ordering-date card shows.
enum HomeOrderingState {
  /// Before Start Ordering By.
  before,

  /// On or after it, with gifts still To Buy.
  needsOrdering,

  /// On or after it, nothing left To Buy.
  allOrdered,

  /// A previous year opened read-only.
  readOnly,
}

typedef GiftWithRecipient = ({GiftModel gift, RecipientModel recipient});

/// Everything the Home screen shows, computed from the plan's rows.
class HomeData {
  const HomeData({
    required this.plan,
    required this.readOnly,
    required this.today,
    required this.shippingDays,
    required this.startBy,
    required this.orderingState,
    required this.needingOrder,
    required this.giftMoney,
    required this.mealMoney,
    required this.recipientCount,
    required this.mealItemCount,
    required this.previousYears,
  });

  final PlanModel plan;
  final bool readOnly;
  final DateTime today;
  final int shippingDays;
  final DateTime startBy;
  final HomeOrderingState orderingState;

  /// To Buy gifts on or after the date, by recipient name then gift name.
  final List<GiftWithRecipient> needingOrder;
  final MoneyTriple giftMoney;
  final MoneyTriple mealMoney;
  final int recipientCount;
  final int mealItemCount;
  final List<int> previousYears;

  int get year => plan.year;
  int get daysToStart => daysUntil(startBy, today);
  int get daysToChristmas => daysUntil(christmas(year), today);
  bool get hasRecipients => recipientCount > 0;
  bool get hasGifts => giftMoney.plannedCount > 0;
}

/// Pure: the same inputs always give the same HomeData.
HomeData buildHomeData({
  required PlanModel plan,
  required bool readOnly,
  required DateTime today,
  required int shippingDays,
  required List<RecipientModel> recipients,
  required List<GiftModel> gifts,
  required List<MealModel> meals,
  required List<MealItemModel> items,
  required List<int> previousYears,
}) {
  final startBy = startOrderingBy(plan.year, shippingDays);
  final byId = {for (final r in recipients) r.id: r};

  final needing =
      <GiftWithRecipient>[
        for (final g in gifts)
          if (byId.containsKey(g.recipientId) &&
              giftNeedsOrderingNow(
                status: g.status,
                today: today,
                startBy: startBy,
              ))
            (gift: g, recipient: byId[g.recipientId]!),
      ]..sort((a, b) {
        final byName = a.recipient.name.compareTo(b.recipient.name);
        return byName != 0 ? byName : a.gift.name.compareTo(b.gift.name);
      });

  final HomeOrderingState state;
  if (readOnly) {
    state = HomeOrderingState.readOnly;
  } else if (daysUntil(startBy, today) > 0) {
    state = HomeOrderingState.before;
  } else if (needing.isNotEmpty) {
    state = HomeOrderingState.needsOrdering;
  } else {
    state = HomeOrderingState.allOrdered;
  }

  final mealTriples = [
    for (final m in meals)
      mealMoney([
        for (final i in items)
          if (i.mealId == m.id) i,
      ], budget: m.budgetLimit),
  ];

  return HomeData(
    plan: plan,
    readOnly: readOnly,
    today: today,
    shippingDays: shippingDays,
    startBy: startBy,
    orderingState: state,
    needingOrder: needing,
    giftMoney: giftMoney(gifts, budget: plan.giftBudgetTotal),
    mealMoney: sumMoney(mealTriples),
    recipientCount: recipients.length,
    mealItemCount: items.length,
    previousYears: previousYears,
  );
}

final homeDataProvider = Provider<AsyncValue<HomeData>>((ref) {
  final plan = ref.watch(selectedPlanProvider);
  final recipients = ref.watch(recipientsProvider);
  final gifts = ref.watch(giftsProvider);
  final meals = ref.watch(mealsProvider);
  final items = ref.watch(mealItemsProvider);
  final profile = ref.watch(userProfileProvider);

  for (final v in [plan, recipients, gifts, meals, items, profile]) {
    if (v.hasError) return AsyncError(v.error!, StackTrace.current);
  }
  final p = plan.asData?.value;
  final r = recipients.asData?.value;
  final g = gifts.asData?.value;
  final m = meals.asData?.value;
  final i = items.asData?.value;
  if (p == null || r == null || g == null || m == null || i == null) {
    return const AsyncLoading();
  }
  // Settings may still be loading; the default shipping days are fine then.
  final shipping =
      profile.asData?.value?.defaultShippingDays ?? defaultShippingDays;

  return AsyncData(
    buildHomeData(
      plan: p,
      readOnly: ref.watch(readOnlyProvider),
      today: ref.watch(todayProvider),
      shippingDays: shipping,
      recipients: r,
      gifts: g,
      meals: m,
      items: i,
      previousYears: ref.watch(previousYearsProvider),
    ),
  );
});

/// Counts To Buy gifts per recipient on or after the date, for the tags on
/// the Gifts list.
Map<String, int> needingOrderByRecipient(HomeData data) {
  final counts = <String, int>{};
  for (final n in data.needingOrder) {
    counts.update(n.recipient.id, (c) => c + 1, ifAbsent: () => 1);
  }
  return counts;
}

/// Whether a gift still To Buy should be marked.
bool giftIsLate(HomeData data, GiftStatus status) => giftNeedsOrderingNow(
  status: status,
  today: data.today,
  startBy: data.startBy,
);
