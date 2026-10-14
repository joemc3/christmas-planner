import 'package:flutter/material.dart';

import '../../core/domain/money.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/season_theme.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/format.dart';
import 'tag.dart';

/// The budget bar: primary fill easing to its width, error at 100% when over.
class BudgetBar extends StatelessWidget {
  const BudgetBar({
    super.key,
    required this.fraction,
    required this.over,
    this.height = 8,
  });

  final double fraction;
  final bool over;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: scheme.surfaceContainerHighest),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(end: over ? 1 : fraction),
                duration: Motion.bar,
                curve: Motion.curve,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0, 1),
                  child: ColoredBox(
                    color: over ? scheme.error : scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum MoneySize { large, home, compact }

/// Budget, spent and remaining with one bar, in the three forms the design
/// draws. Remaining is the number (principle 1); over budget changes the
/// words, the bar and adds a tag.
class MoneyTripleView extends StatelessWidget {
  const MoneyTripleView({
    super.key,
    required this.money,
    required this.currency,
    this.size = MoneySize.large,
    this.budgetLabel = 'Budget',
    this.onEditBudget,
    this.onSetBudget,
    this.unsetLabel = 'No budget set yet',
    this.setLabel = 'Set budget',
  });

  final MoneyTriple money;
  final String currency;
  final MoneySize size;
  final String budgetLabel;

  /// When set, the budget figure becomes a button that opens the editor.
  final VoidCallback? onEditBudget;

  /// When set and the budget is 0, shows the set-budget button instead.
  final VoidCallback? onSetBudget;
  final String unsetLabel;
  final String setLabel;

  String _m(double v) => formatMoney(v, currency: currency);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    if (!money.hasBudget && onSetBudget != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              unsetLabel,
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          FilledButton.tonal(onPressed: onSetBudget, child: Text(setLabel)),
        ],
      );
    }

    final over = money.isOverBudget;
    final semantics = over
        ? '${_m(money.overBy)} over budget. Spent ${_m(money.spent)} of ${_m(money.budget)}.'
        : '${_m(money.remaining)} left of ${_m(money.budget)}. Spent ${_m(money.spent)}.';

    switch (size) {
      case MoneySize.compact:
        return Semantics(
          label: semantics,
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: over
                          ? RichText(
                              text: TextSpan(
                                style: tabular(text.bodyMedium),
                                children: [
                                  TextSpan(
                                    text: '${_m(money.overBy)} over',
                                    style: TextStyle(
                                      color: scheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' · budget ${_m(money.budget)}',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: tabular(text.bodyMedium),
                                children: [
                                  TextSpan(
                                    text: _m(money.remaining),
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' left of ${_m(money.budget)}',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    if (over) ...[
                      const SizedBox(width: Space.sm),
                      Tag.alert(
                        context,
                        'Over budget',
                        icon: Icons.warning_rounded,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: Space.sm),
                BudgetBar(fraction: money.fraction, over: over, height: 6),
              ],
            ),
          ),
        );

      case MoneySize.large:
      case MoneySize.home:
        final season = SeasonTheme.of(context);
        final big = size == MoneySize.large
            ? season.moneyLarge
            : season.moneyHome;
        return Semantics(
          label: semantics,
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      over ? 'Over budget' : 'Left to spend',
                      style: text.bodyMedium?.copyWith(
                        color: over ? scheme.error : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (over) ...[
                      const SizedBox(width: Space.sm),
                      Tag.alert(
                        context,
                        'Over budget',
                        icon: Icons.warning_rounded,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: Space.xs),
                Text(
                  over ? '${_m(money.overBy)} over' : _m(money.remaining),
                  style: over ? big.copyWith(color: scheme.error) : big,
                ),
                const SizedBox(height: Space.md),
                BudgetBar(fraction: money.fraction, over: over),
                const SizedBox(height: Space.md),
                Row(
                  children: [
                    _Figure(label: 'Spent', value: _m(money.spent)),
                    const SizedBox(width: Space.xl),
                    _Figure(
                      label: budgetLabel,
                      value: _m(money.budget),
                      onTap: onEditBudget,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
    }
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: tabular(
                text.titleMedium,
              ).copyWith(color: onTap != null ? scheme.primary : null),
            ),
            if (onTap != null) ...[
              const SizedBox(width: Space.xs),
              Icon(Icons.edit_rounded, size: 16, color: scheme.primary),
            ],
          ],
        ),
      ],
    );
    if (onTap == null) return column;
    return Semantics(
      button: true,
      label: 'Edit $label, $value',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.field),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.xs,
              vertical: 2,
            ),
            child: column,
          ),
        ),
      ),
    );
  }
}
