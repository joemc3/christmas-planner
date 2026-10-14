import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/gift_model.dart';
import '../providers/gift_providers.dart';
import '../widgets/gift_form_sheet.dart';
import 'recipient_detail_screen.dart' show giftStatusColor, giftStatusIcon;

class GiftDetailScreen extends ConsumerWidget {
  final String giftId;

  const GiftDetailScreen({super.key, required this.giftId});

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    GiftModel gift,
    GiftStatus status,
  ) async {
    if (status == gift.status) return;
    final now = DateTime.now();
    // Keep the audit dates in step with the status the user picks.
    final updated = gift.copyWith(
      status: status,
      orderDate: status == GiftStatus.ordered && gift.orderDate == null
          ? now
          : null,
      actualDeliveryDate:
          status == GiftStatus.delivered && gift.actualDeliveryDate == null
          ? now
          : null,
      wrappedDate: status == GiftStatus.wrapped && gift.wrappedDate == null
          ? now
          : null,
    );
    try {
      await ref.read(giftControllerProvider).updateGift(updated);
      ref.invalidate(giftByIdProvider(gift.id));
      ref.invalidate(giftBudgetStatsProvider);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    GiftModel gift,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete gift?',
        message: '"${gift.name}" will be removed from the list.',
        confirmText: 'Delete',
        isDestructive: true,
        icon: Icons.delete_outline,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(giftControllerProvider).deleteGift(gift.id);
      ref.invalidate(giftBudgetStatsProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final giftAsync = ref.watch(giftByIdProvider(giftId));

    return giftAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (gift) {
        if (gift == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.search_off,
              title: 'Gift not found',
            ),
          );
        }
        final recipientAsync = ref.watch(
          recipientByIdProvider(gift.recipientId),
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(gift.name),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => GiftFormSheet.show(
                  context,
                  recipientId: gift.recipientId,
                  existing: gift,
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref, gift),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            children: [
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          giftStatusIcon(gift.status),
                          color: giftStatusColor(gift.status),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'For ${recipientAsync.value?.name ?? '…'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          AppDateUtils.formatCurrency(gift.effectivePrice),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (gift.actualPrice != null &&
                        gift.actualPrice != gift.price)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Planned ${AppDateUtils.formatCurrency(gift.price)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in GiftStatus.values)
                          ChoiceChip(
                            label: Text(s.value),
                            avatar: Icon(giftStatusIcon(s), size: 18),
                            selected: gift.status == s,
                            selectedColor: giftStatusColor(
                              s,
                            ).withValues(alpha: 0.2),
                            onSelected: (_) =>
                                _setStatus(context, ref, gift, s),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Detail('Category', gift.category),
                    _Detail('Store', gift.storeName),
                    _Detail('Link', gift.orderLink, isLink: true),
                    _Detail(
                      'Ordered',
                      gift.orderDate == null
                          ? null
                          : AppDateUtils.formatDate(gift.orderDate),
                    ),
                    _Detail(
                      'Expected delivery',
                      gift.expectedDeliveryDate == null
                          ? null
                          : AppDateUtils.formatDate(gift.expectedDeliveryDate),
                    ),
                    _Detail(
                      'Delivered',
                      gift.actualDeliveryDate == null
                          ? null
                          : AppDateUtils.formatDate(gift.actualDeliveryDate),
                    ),
                    _Detail('Tracking', gift.trackingNumber),
                    _Detail(
                      'Wrapped',
                      gift.wrappedDate == null
                          ? null
                          : AppDateUtils.formatDate(gift.wrappedDate),
                    ),
                    _Detail('Surprise', gift.isSurprise ? 'Yes' : 'No'),
                    _Detail('Notes', gift.notes),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String? value;
  final bool isLink;

  const _Detail(this.label, this.value, {this.isLink = false});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: isLink
                ? SelectableText(
                    value!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: FrostedHearthColors.info,
                      decoration: TextDecoration.underline,
                    ),
                  )
                : Text(value!, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
