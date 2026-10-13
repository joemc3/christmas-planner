import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/recipient_model.dart';
import '../providers/gift_providers.dart';
import '../widgets/recipient_form_sheet.dart';

class GiftsScreen extends ConsumerWidget {
  const GiftsScreen({super.key});

  Future<void> _addRecipient(BuildContext context, WidgetRef ref) async {
    final created = await RecipientFormSheet.show(context);
    if (created != null && context.mounted) {
      await context.push('/gifts/recipient/${created.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipientsAsync = ref.watch(recipientsStreamProvider);
    final giftsAsync = ref.watch(giftsStreamProvider);
    final gifts = giftsAsync.value ?? const <GiftModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Gifts')),
      body: recipientsAsync.when(
        data: (recipients) {
          if (recipients.isEmpty) {
            return EmptyState(
              icon: Icons.card_giftcard,
              title: 'Nobody on your list yet',
              subtitle:
                  'Add the people you are buying for, set a budget for each, '
                  'then track gifts from idea to wrapped.',
              actionText: 'Add first recipient',
              onAction: () => _addRecipient(context, ref),
            );
          }

          final giftsByRecipient = <String, List<GiftModel>>{};
          for (final g in gifts) {
            giftsByRecipient.putIfAbsent(g.recipientId, () => []).add(g);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _GiftsSummaryCard(recipients: recipients, gifts: gifts),
              const SizedBox(height: 16),
              for (final recipient in recipients)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RecipientTile(
                    recipient: recipient,
                    gifts: giftsByRecipient[recipient.id] ?? const [],
                    onTap: () =>
                        context.push('/gifts/recipient/${recipient.id}'),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load recipients',
          subtitle: error.toString(),
          actionText: 'Retry',
          onAction: () => ref.invalidate(recipientsStreamProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRecipient(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Recipient'),
      ),
    );
  }
}

class _GiftsSummaryCard extends StatelessWidget {
  final List<RecipientModel> recipients;
  final List<GiftModel> gifts;

  const _GiftsSummaryCard({required this.recipients, required this.gifts});

  @override
  Widget build(BuildContext context) {
    final budget = recipients.fold<double>(0, (s, r) => s + r.budgetLimit);
    final planned = gifts.fold<double>(0, (s, g) => s + g.price);
    final done = gifts.where((g) => g.status != GiftStatus.toBuy).length;

    return FrostedCard(
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Budget',
              value: AppDateUtils.formatCurrency(budget),
            ),
          ),
          Expanded(
            child: _Stat(
              label: 'Planned',
              value: AppDateUtils.formatCurrency(planned),
              color: planned > budget && budget > 0
                  ? FrostedHearthColors.error
                  : null,
            ),
          ),
          Expanded(
            child: _Stat(label: 'Bought', value: '$done / ${gifts.length}'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RecipientTile extends StatelessWidget {
  final RecipientModel recipient;
  final List<GiftModel> gifts;
  final VoidCallback onTap;

  const _RecipientTile({
    required this.recipient,
    required this.gifts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final planned = gifts.fold<double>(0, (s, g) => s + g.effectivePrice);
    final hasBudget = recipient.budgetLimit > 0;
    final ratio = hasBudget ? (planned / recipient.budgetLimit) : 0.0;
    final over = hasBudget && planned > recipient.budgetLimit;
    final wrapped = gifts
        .where(
          (g) =>
              g.status == GiftStatus.wrapped ||
              g.status == GiftStatus.delivered,
        )
        .length;

    return FrostedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: FrostedHearthColors.spruce,
            child: Text(
              recipient.name.isEmpty ? '?' : recipient.name[0].toUpperCase(),
              style: const TextStyle(
                color: FrostedHearthColors.frostGold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipient.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      hasBudget
                          ? '${AppDateUtils.formatCurrency(planned)} / '
                                '${AppDateUtils.formatCurrency(recipient.budgetLimit)}'
                          : AppDateUtils.formatCurrency(planned),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: over ? FrostedHearthColors.error : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: hasBudget ? ratio.clamp(0, 1) : 0,
                    minHeight: 6,
                    backgroundColor: FrostedHearthColors.parchmentWarm,
                    color: over
                        ? FrostedHearthColors.error
                        : FrostedHearthColors.ember,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (recipient.relationship != null) recipient.relationship!,
                    gifts.isEmpty
                        ? 'No gifts yet'
                        : '${gifts.length} gift${gifts.length == 1 ? '' : 's'}'
                              ', $wrapped wrapped',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: FrostedHearthColors.inkLight),
        ],
      ),
    );
  }
}
