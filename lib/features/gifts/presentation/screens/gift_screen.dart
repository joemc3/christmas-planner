import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/season_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/confirm.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/states.dart';
import '../../../../shared/widgets/status_stepper.dart';
import '../../../../shared/widgets/undo_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/gift_model.dart';
import '../providers/gift_providers.dart';
import '../widgets/gift_form.dart';

/// B4: a reference card for the shop.
class GiftScreen extends ConsumerWidget {
  const GiftScreen({
    super.key,
    required this.recipientId,
    required this.giftId,
  });

  final String recipientId;
  final String giftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final season = SeasonTheme.of(context);
    final gift = ref.watch(giftByIdProvider(giftId));
    final recipient = ref
        .watch(recipientByIdProvider(recipientId))
        .asData
        ?.value;
    final readOnly = ref.watch(readOnlyProvider);
    final currency =
        ref.watch(userProfileProvider).asData?.value?.currency ?? 'USD';
    final money = recipient == null
        ? null
        : ref.watch(recipientMoneyProvider(recipient));

    Future<void> edit(GiftModel g) async {
      if (recipient == null || money == null) return;
      await showGiftForm(
        context,
        recipient: recipient,
        money: money,
        currency: currency,
        gift: g,
      );
    }

    Future<void> delete(GiftModel g) async {
      final ok = await confirm(
        context,
        title: 'Delete ${g.name}?',
        body: recipient == null
            ? 'It comes off the list, and the totals update.'
            : "It comes off ${recipient.name}'s list, and the totals update.",
        actionLabel: 'Delete',
      );
      if (!ok) return;
      await ref.read(giftControllerProvider).deleteGift(g.id);
      if (context.mounted) context.go('/gifts/$recipientId');
    }

    Future<void> setStatus(GiftModel g, GiftStatus to) async {
      if (to == g.status) return;
      final controller = ref.read(giftControllerProvider);
      final previous = await controller.setStatus(g, to);
      if (!context.mounted) return;
      showUndoSnackBar(
        context,
        message: '${g.name} marked ${to.value}.',
        onUndo: () => controller.restore(previous),
      );
    }

    final g = gift.asData?.value;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/gifts/$recipientId')),
        actions: [
          if (g != null && !readOnly)
            IconButton(
              tooltip: 'Edit gift',
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => edit(g),
            ),
        ],
      ),
      body: ReadableColumn(
        child: asyncList(
          gift,
          errorMessage: "Couldn't load this gift.",
          onRetry: () => ref.invalidate(ensuredPlanProvider),
          skeletonCount: 2,
          data: (g) {
            if (g == null) {
              return const Center(
                child: Text('This gift is no longer in the plan.'),
              );
            }
            final store = g.storeLabel;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                0,
                Space.lg,
                Space.xxxl,
              ),
              children: [
                if (recipient != null && money != null)
                  Text(
                    'For ${recipient.name} · '
                    '${formatMoney(money.remaining, currency: currency)} left of '
                    '${formatMoney(money.budget, currency: currency)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: Space.sm),
                Text(g.name, style: theme.textTheme.headlineMedium),
                const SizedBox(height: Space.sm),
                Text(
                  formatMoney(g.price, currency: currency),
                  style: season.moneyLarge,
                ),
                if (store != null) ...[
                  const SizedBox(height: Space.md),
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: SelectableText(
                          g.orderLink ?? store,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SectionHeader(title: 'Status'),
                IgnorePointer(
                  ignoring: readOnly,
                  child: GiftStatusSegmented(
                    value: g.status,
                    onChanged: (to) => setStatus(g, to),
                  ),
                ),
                if (g.orderDate != null)
                  _DateLine(
                    icon: Icons.local_shipping_rounded,
                    label: 'Ordered on',
                    date: g.orderDate!,
                    onEdit: readOnly ? null : () => edit(g),
                  ),
                if (g.purchasedDate != null)
                  _DateLine(
                    icon: Icons.check_rounded,
                    label: 'Purchased on',
                    date: g.purchasedDate!,
                    onEdit: readOnly ? null : () => edit(g),
                  ),
                if (!readOnly) ...[
                  const SizedBox(height: Space.xxl),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: () => delete(g),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete gift'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DateLine extends StatelessWidget {
  const _DateLine({
    required this.icon,
    required this.label,
    required this.date,
    required this.onEdit,
  });

  final IconData icon;
  final String label;
  final DateTime date;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Space.lg),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(formatLongDate(date), style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit $label',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_calendar_rounded),
            ),
        ],
      ),
    );
  }
}
