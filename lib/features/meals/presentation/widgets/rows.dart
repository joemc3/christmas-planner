import 'package:flutter/material.dart';

import '../../../../core/domain/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/money_triple_view.dart';
import '../../../../shared/widgets/status_stepper.dart';
import '../../data/models/meal_item_model.dart';
import '../../data/models/meal_model.dart';

/// Meal name, date and guests, remaining of budget, bought of planned; or
/// "No budget set yet" with Set budget.
class MealRow extends StatelessWidget {
  const MealRow({
    super.key,
    required this.meal,
    required this.money,
    required this.currency,
    required this.year,
    required this.onTap,
    this.onSetBudget,
    this.selected = false,
  });

  final MealModel meal;
  final MoneyTriple money;
  final String currency;
  final int year;
  final VoidCallback onTap;
  final VoidCallback? onSetBudget;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final guests = meal.hasGuests
        ? '${meal.guestCount} ${meal.guestCount == 1 ? 'guest' : 'guests'}'
        : 'Guests not set';
    return Material(
      color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.name, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDayMonth(meal.type.dateIn(year))} · $guests',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    MoneyTripleView(
                      money: money,
                      currency: currency,
                      size: MoneySize.compact,
                      onSetBudget: onSetBudget,
                    ),
                    if (money.hasBudget) ...[
                      const SizedBox(height: Space.xs),
                      Text(
                        '${money.purchasedCount} of ${money.plannedCount} bought',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

/// Name; cost and status; the two-cell stepper.
class MenuItemRow extends StatelessWidget {
  const MenuItemRow({
    super.key,
    required this.item,
    required this.currency,
    required this.onTap,
    required this.onForward,
    this.enabled = true,
  });

  final MealItemModel item;
  final String currency;
  final VoidCallback onTap;
  final ValueChanged<MealItemStatus>? onForward;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bought = item.status == MealItemStatus.purchased;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: tabular(
                        theme.textTheme.bodyMedium,
                      ).copyWith(color: scheme.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: formatMoney(item.cost, currency: currency),
                        ),
                        const TextSpan(text: ' · '),
                        TextSpan(
                          text: item.status.value,
                          style: TextStyle(
                            color: bought
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Space.md),
            MealItemStepperRow(
              status: item.status,
              onForward: onForward,
              enabled: enabled,
            ),
          ],
        ),
      ),
    );
  }
}
