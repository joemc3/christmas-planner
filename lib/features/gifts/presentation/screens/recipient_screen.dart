import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/confirm.dart';
import '../../../../shared/widgets/money_triple_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/states.dart';
import '../../../../shared/widgets/undo_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_data.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/recipient_model.dart';
import '../providers/gift_providers.dart';
import '../widgets/gift_form.dart';
import '../widgets/recipient_form.dart';
import '../widgets/rows.dart';

/// B3: one person. [embedded] is the detail pane of the expanded layout:
/// no back button, no scaffold of its own.
class RecipientScreen extends ConsumerWidget {
  const RecipientScreen({
    super.key,
    required this.recipientId,
    this.embedded = false,
  });

  final String recipientId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipient = ref.watch(recipientByIdProvider(recipientId));
    final readOnly = ref.watch(readOnlyProvider);
    final currency =
        ref.watch(userProfileProvider).asData?.value?.currency ?? 'USD';
    final r = recipient.asData?.value;
    final money = r == null ? null : ref.watch(recipientMoneyProvider(r));

    Future<void> edit() async {
      if (r == null || money == null) return;
      final plan = ref.read(selectedPlanProvider).asData?.value;
      if (plan == null) return;
      await showRecipientForm(
        context,
        planId: plan.id,
        currency: currency,
        recipient: r,
        spentSoFar: money.spent,
      );
    }

    Future<void> delete() async {
      if (r == null || money == null) return;
      final n = money.plannedCount;
      final ok = await confirm(
        context,
        title: 'Delete ${r.name}?',
        body: n == 0
            ? '${r.name} has no gifts yet.'
            : "${r.name}'s $n ${n == 1 ? 'gift is' : 'gifts are'} deleted too.",
        actionLabel: 'Delete',
      );
      if (!ok) return;
      await ref.read(giftControllerProvider).deleteRecipient(r.id);
      if (context.mounted && !embedded) context.go('/gifts');
    }

    Future<void> addGift() async {
      if (r == null || money == null) return;
      await showGiftForm(
        context,
        recipient: r,
        money: money,
        currency: currency,
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        leading: embedded
            ? null
            : BackButton(onPressed: () => context.go('/gifts')),
        title: Text(r?.name ?? ''),
        actions: [
          if (r != null && !readOnly) ...[
            IconButton(
              tooltip: 'Edit person',
              icon: const Icon(Icons.edit_rounded),
              onPressed: edit,
            ),
            IconButton(
              tooltip: 'Delete person',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: delete,
            ),
          ],
        ],
      ),
      floatingActionButton: r == null || readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: addGift,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add gift'),
            ),
      body: ReadableColumn(
        child: asyncList(
          recipient,
          errorMessage: "Couldn't load this person.",
          onRetry: () => ref.invalidate(ensuredPlanProvider),
          data: (r) => r == null
              ? const Center(
                  child: Text('This person is no longer in the plan.'),
                )
              : _RecipientBody(
                  recipient: r,
                  currency: currency,
                  readOnly: readOnly,
                  onAddGift: addGift,
                ),
        ),
      ),
    );
  }
}

class _RecipientBody extends ConsumerWidget {
  const _RecipientBody({
    required this.recipient,
    required this.currency,
    required this.readOnly,
    required this.onAddGift,
  });

  final RecipientModel recipient;
  final String currency;
  final bool readOnly;
  final VoidCallback onAddGift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gifts = ref.watch(giftsByRecipientProvider(recipient.id));
    final money = ref.watch(recipientMoneyProvider(recipient));
    final home = ref.watch(homeDataProvider).asData?.value;
    final today = ref.watch(todayProvider);
    final startBy = home?.startBy ?? today;

    Future<void> forward(GiftModel gift, GiftStatus to) async {
      final controller = ref.read(giftControllerProvider);
      try {
        final previous = await controller.setStatus(gift, to);
        if (!context.mounted) return;
        showUndoSnackBar(
          context,
          message: '${gift.name} marked ${to.value}.',
          onUndo: () => controller.restore(previous),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Couldn't update ${gift.name}.")),
          );
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, 0),
          child: MoneyTripleView(money: money, currency: currency),
        ),
        if (money.isPlannedOver)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  size: 16,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    'Planned ${formatMoney(money.planned, currency: currency)}, '
                    '${formatMoney(money.plannedOverBy, currency: currency)} '
                    'more than the budget',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          child: SectionHeader(
            title: 'Gifts',
            trailing: money.plannedCount == 0
                ? null
                : '${money.purchasedCount} of ${money.plannedCount} bought',
          ),
        ),
        asyncList(
          gifts,
          errorMessage: "Couldn't load ${recipient.name}'s gifts.",
          onRetry: () => ref.invalidate(ensuredPlanProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  message: 'No gifts yet for ${recipient.name}.',
                  actionLabel: readOnly ? null : 'Add gift',
                  onAction: readOnly ? null : onAddGift,
                )
              : Column(
                  children: [
                    const Divider(),
                    for (final g in list) ...[
                      GiftRow(
                        gift: g,
                        currency: currency,
                        startBy: startBy,
                        late: home != null && giftIsLate(home, g.status),
                        enabled: !readOnly,
                        onTap: () =>
                            context.go('/gifts/${recipient.id}/gift/${g.id}'),
                        onForward: readOnly ? null : (to) => forward(g, to),
                      ),
                      const Divider(),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
