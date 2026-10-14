import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/money.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/recipient_model.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/recipient_repository.dart';

final recipientRepositoryProvider = Provider<RecipientRepository>(
  (ref) => RecipientRepository(),
);

final giftRepositoryProvider = Provider<GiftRepository>(
  (ref) => GiftRepository(),
);

/// Recipients of the selected plan, by name. Live.
final recipientsProvider = Provider<AsyncValue<List<RecipientModel>>>((ref) {
  final plan = ref.watch(selectedPlanProvider);
  return plan.when(
    data: (p) => ref.watch(_recipientsOfPlanProvider(p.id)),
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
  );
});

final _recipientsOfPlanProvider =
    StreamProvider.family<List<RecipientModel>, String>(
      (ref, planId) =>
          ref.watch(recipientRepositoryProvider).watchRecipients(planId),
    );

/// Every gift the user can see, across plans. Live.
final _allGiftsProvider = StreamProvider<List<GiftModel>>(
  (ref) => ref.watch(giftRepositoryProvider).watchAllGifts(),
);

/// The selected plan's gifts: all gifts whose recipient is in the plan.
final giftsProvider = Provider<AsyncValue<List<GiftModel>>>((ref) {
  final recipients = ref.watch(recipientsProvider);
  final gifts = ref.watch(_allGiftsProvider);
  if (recipients.hasError) {
    return AsyncError(recipients.error!, StackTrace.current);
  }
  if (gifts.hasError) return AsyncError(gifts.error!, StackTrace.current);
  final r = recipients.asData?.value;
  final g = gifts.asData?.value;
  if (r == null || g == null) return const AsyncLoading();
  final ids = {for (final x in r) x.id};
  return AsyncData([
    for (final gift in g)
      if (ids.contains(gift.recipientId)) gift,
  ]);
});

final giftsByRecipientProvider =
    Provider.family<AsyncValue<List<GiftModel>>, String>(
      (ref, recipientId) => ref
          .watch(giftsProvider)
          .whenData(
            (all) => [
              for (final g in all)
                if (g.recipientId == recipientId) g,
            ],
          ),
    );

final recipientByIdProvider =
    Provider.family<AsyncValue<RecipientModel?>, String>(
      (ref, id) => ref.watch(recipientsProvider).whenData((all) {
        final found = all.where((r) => r.id == id);
        return found.isEmpty ? null : found.first;
      }),
    );

final giftByIdProvider = Provider.family<AsyncValue<GiftModel?>, String>(
  (ref, id) => ref.watch(giftsProvider).whenData((all) {
    final found = all.where((g) => g.id == id);
    return found.isEmpty ? null : found.first;
  }),
);

/// Money for one person: budget from the recipient, sums from their gifts.
final recipientMoneyProvider = Provider.family<MoneyTriple, RecipientModel>((
  ref,
  recipient,
) {
  final gifts = ref.watch(giftsByRecipientProvider(recipient.id)).asData?.value;
  return giftMoney(gifts ?? const [], budget: recipient.budgetLimit);
});

final giftControllerProvider = Provider<GiftController>(
  (ref) => GiftController(ref),
);

class GiftController {
  GiftController(this._ref);
  final Ref _ref;

  RecipientRepository get _recipients => _ref.read(recipientRepositoryProvider);
  GiftRepository get _gifts => _ref.read(giftRepositoryProvider);

  Future<RecipientModel> createRecipient({
    required String planId,
    required String name,
    required double budgetLimit,
  }) => _recipients.createRecipient(
    planId: planId,
    name: name,
    budgetLimit: budgetLimit,
  );

  Future<RecipientModel> updateRecipient(RecipientModel r) =>
      _recipients.updateRecipient(r);

  Future<void> deleteRecipient(String id) => _recipients.deleteRecipient(id);

  Future<GiftModel> createGift(GiftModel g) => _gifts.createGift(g);

  Future<GiftModel> updateGift(GiftModel g) => _gifts.updateGift(g);

  Future<void> deleteGift(String id) => _gifts.deleteGift(id);

  /// Applies a status change with its date rules and returns the gift as it
  /// was, for Undo.
  Future<GiftModel> setStatus(GiftModel gift, GiftStatus to) async {
    final today = _ref.read(todayProvider);
    await _gifts.updateGift(gift.withStatus(to, today: today));
    return gift;
  }

  /// Restores a gift exactly (status and both dates).
  Future<void> restore(GiftModel previous) => _gifts.updateGift(previous);
}
