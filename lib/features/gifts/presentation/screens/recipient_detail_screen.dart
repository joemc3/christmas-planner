import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/recipient_model.dart';
import '../providers/gift_providers.dart';
import '../widgets/gift_form_sheet.dart';
import '../widgets/recipient_form_sheet.dart';

class RecipientDetailScreen extends ConsumerWidget {
  final String recipientId;

  const RecipientDetailScreen({super.key, required this.recipientId});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RecipientModel recipient,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete ${recipient.name}?',
        message: 'Their gifts will be deleted too. This cannot be undone.',
        confirmText: 'Delete',
        isDestructive: true,
        icon: Icons.delete_outline,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(recipientControllerProvider).deleteRecipient(recipient.id);
      ref.invalidate(giftBudgetStatsProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientAsync = ref.watch(recipientByIdProvider(recipientId));
    final giftsAsync = ref.watch(giftsByRecipientProvider(recipientId));

    return recipientAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (recipient) {
        if (recipient == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Recipient not found',
            ),
          );
        }
        final gifts = giftsAsync.value ?? const <GiftModel>[];
        return Scaffold(
          appBar: AppBar(
            title: Text(recipient.name),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    RecipientFormSheet.show(context, existing: recipient),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') _delete(context, ref, recipient);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete recipient'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            children: [
              _RecipientHeader(recipient: recipient, gifts: gifts),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Gifts',
                actionText: 'Add gift',
                onAction: () =>
                    GiftFormSheet.show(context, recipientId: recipient.id),
              ),
              giftsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Error: $e'),
                data: (gifts) {
                  if (gifts.isEmpty) {
                    return EmptyState(
                      icon: Icons.redeem,
                      title: 'No gift ideas yet',
                      subtitle: recipient.interests.isEmpty
                          ? 'Add the first idea for ${recipient.name}.'
                          : 'Into ${recipient.interests.join(', ')}. '
                                'Add the first idea.',
                      actionText: 'Add gift',
                      onAction: () => GiftFormSheet.show(
                        context,
                        recipientId: recipient.id,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final gift in gifts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GiftTile(
                            gift: gift,
                            onTap: () => context.push('/gifts/gift/${gift.id}'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: FloatingActionButton.extended(
              onPressed: () =>
                  GiftFormSheet.show(context, recipientId: recipient.id),
              icon: const Icon(Icons.add),
              label: const Text('Gift'),
            ),
          ),
        );
      },
    );
  }
}

class _RecipientHeader extends StatelessWidget {
  final RecipientModel recipient;
  final List<GiftModel> gifts;

  const _RecipientHeader({required this.recipient, required this.gifts});

  @override
  Widget build(BuildContext context) {
    final planned = gifts.fold<double>(0, (s, g) => s + g.effectivePrice);
    final spent = gifts
        .where((g) => g.status != GiftStatus.toBuy)
        .fold<double>(0, (s, g) => s + g.effectivePrice);
    final budget = recipient.budgetLimit;
    final remaining = budget - planned;

    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: FrostedHearthColors.spruce,
                child: Text(
                  recipient.name.isEmpty
                      ? '?'
                      : recipient.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: FrostedHearthColors.frostGold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        if (recipient.relationship != null)
                          recipient.relationship!,
                        if (recipient.ageGroup != null) recipient.ageGroup!,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (recipient.interests.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final i in recipient.interests)
                            Chip(
                              label: Text(i),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Money(
                  'Budget',
                  budget,
                  hint: budget == 0 ? 'not set' : null,
                ),
              ),
              Expanded(child: _Money('Planned', planned)),
              Expanded(child: _Money('Spent', spent)),
              Expanded(
                child: _Money(
                  'Left',
                  remaining,
                  color: remaining < 0 ? FrostedHearthColors.error : null,
                ),
              ),
            ],
          ),
          if (budget > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (planned / budget).clamp(0, 1),
                minHeight: 8,
                backgroundColor: FrostedHearthColors.parchmentWarm,
                color: planned > budget
                    ? FrostedHearthColors.error
                    : FrostedHearthColors.ember,
              ),
            ),
          ],
          if (recipient.notes != null && recipient.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              recipient.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _Money extends StatelessWidget {
  final String label;
  final double amount;
  final String? hint;
  final Color? color;

  const _Money(this.label, this.amount, {this.hint, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          hint ?? AppDateUtils.formatCurrency(amount),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// One gift in a list, with its status colour.
class GiftTile extends StatelessWidget {
  final GiftModel gift;
  final VoidCallback onTap;

  const GiftTile({super.key, required this.gift, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            giftStatusIcon(gift.status),
            color: giftStatusColor(gift.status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    gift.status.value,
                    if (gift.storeName != null) gift.storeName!,
                    if (gift.expectedDeliveryDate != null &&
                        gift.status == GiftStatus.ordered)
                      'arrives ${AppDateUtils.formatDate(gift.expectedDeliveryDate)}',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppDateUtils.formatCurrency(gift.effectivePrice),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

IconData giftStatusIcon(GiftStatus status) => switch (status) {
  GiftStatus.toBuy => Icons.lightbulb_outline,
  GiftStatus.ordered => Icons.local_shipping_outlined,
  GiftStatus.purchased => Icons.shopping_bag_outlined,
  GiftStatus.wrapped => Icons.card_giftcard,
  GiftStatus.delivered => Icons.check_circle_outline,
};

Color giftStatusColor(GiftStatus status) => switch (status) {
  GiftStatus.toBuy => FrostedHearthColors.inkLight,
  GiftStatus.ordered => FrostedHearthColors.info,
  GiftStatus.purchased => FrostedHearthColors.ember,
  GiftStatus.wrapped => FrostedHearthColors.winterBerry,
  GiftStatus.delivered => FrostedHearthColors.success,
};
