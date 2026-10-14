import 'package:flutter/material.dart';

import '../../../../core/domain/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/money_triple_view.dart';
import '../../../../shared/widgets/status_stepper.dart';
import '../../../../shared/widgets/tag.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/recipient_model.dart';

/// Monogram, name, remaining first, thin bar, purchased of planned. Over
/// budget changes the words and adds a tag; after the date a "to order" tag.
class RecipientRow extends StatelessWidget {
  const RecipientRow({
    super.key,
    required this.recipient,
    required this.money,
    required this.currency,
    required this.onTap,
    this.toOrder = 0,
    this.selected = false,
  });

  final RecipientModel recipient;
  final MoneyTriple money;
  final String currency;
  final VoidCallback onTap;
  final int toOrder;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(
                  recipient.initial,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: Space.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipient.name,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (toOrder > 0) ...[
                          const SizedBox(width: Space.sm),
                          Tag.alert(
                            context,
                            '$toOrder to order',
                            icon: Icons.schedule_rounded,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Space.sm),
                    MoneyTripleView(
                      money: money,
                      currency: currency,
                      size: MoneySize.compact,
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      '${money.purchasedCount} of ${money.plannedCount} bought',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.sm),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Name; price and store; a status line; the row stepper.
class GiftRow extends StatelessWidget {
  const GiftRow({
    super.key,
    required this.gift,
    required this.currency,
    required this.startBy,
    required this.late,
    required this.onTap,
    required this.onForward,
    this.enabled = true,
  });

  final GiftModel gift;
  final String currency;
  final DateTime startBy;

  /// To Buy on or after the ordering date.
  final bool late;
  final VoidCallback onTap;
  final ValueChanged<GiftStatus>? onForward;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Widget statusLine;
    switch (gift.status) {
      case GiftStatus.toBuy:
        statusLine = late
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded, size: 14, color: scheme.error),
                  const SizedBox(width: Space.xs),
                  Text(
                    'Order now',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'To Buy · order by ${formatShortDate(startBy)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              );
      case GiftStatus.ordered:
        statusLine = Text(
          gift.orderDate == null
              ? 'Ordered'
              : 'Ordered ${formatShortDate(gift.orderDate!)}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.tertiary),
        );
      case GiftStatus.purchased:
        statusLine = Text(
          gift.purchasedDate == null
              ? 'Purchased'
              : 'Purchased ${formatShortDate(gift.purchasedDate!)}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary),
        );
    }

    final store = gift.storeLabel;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gift.name,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    store == null
                        ? formatMoney(gift.price, currency: currency)
                        : '${formatMoney(gift.price, currency: currency)} · $store',
                    style: tabular(
                      theme.textTheme.bodyMedium,
                    ).copyWith(color: scheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  statusLine,
                ],
              ),
            ),
            const SizedBox(width: Space.md),
            GiftStepperRow(
              status: gift.status,
              onForward: onForward,
              enabled: enabled,
              late: late,
            ),
          ],
        ),
      ),
    );
  }
}
