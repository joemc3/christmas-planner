import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/money_triple_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/states.dart';
import '../../../../shared/widgets/undo_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/meal_item_model.dart';
import '../../data/models/meal_model.dart';
import '../providers/meal_providers.dart';
import '../widgets/meal_forms.dart';
import '../widgets/rows.dart';

/// B6: one meal. Mirrors the recipient screen so the app teaches one pattern.
class MealScreen extends ConsumerWidget {
  const MealScreen({super.key, required this.mealId, this.embedded = false});

  final String mealId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meal = ref.watch(mealByIdProvider(mealId));
    final readOnly = ref.watch(readOnlyProvider);
    final currency =
        ref.watch(userProfileProvider).asData?.value?.currency ?? 'USD';
    final m = meal.asData?.value;
    final money = m == null ? null : ref.watch(mealMoneyProvider(m));

    Future<void> edit() async {
      if (m == null || money == null) return;
      await showMealForm(context, meal: m, money: money, currency: currency);
    }

    Future<void> addItem() async {
      if (m == null || money == null) return;
      await showMealItemForm(
        context,
        meal: m,
        money: money,
        currency: currency,
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        leading: embedded
            ? null
            : BackButton(onPressed: () => context.go('/meals')),
        title: Text(m?.name ?? ''),
        actions: [
          if (m != null && !readOnly)
            IconButton(
              tooltip: 'Edit guests and budget',
              icon: const Icon(Icons.edit_rounded),
              onPressed: edit,
            ),
        ],
      ),
      floatingActionButton: m == null || readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: addItem,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add item'),
            ),
      body: ReadableColumn(
        child: asyncList(
          meal,
          errorMessage: "Couldn't load this meal.",
          onRetry: () => ref.invalidate(ensuredPlanProvider),
          data: (m) => m == null
              ? const Center(child: Text('This meal is not in the plan.'))
              : _MealBody(
                  meal: m,
                  currency: currency,
                  readOnly: readOnly,
                  onAddItem: addItem,
                  onEdit: edit,
                ),
        ),
      ),
    );
  }
}

class _MealBody extends ConsumerWidget {
  const _MealBody({
    required this.meal,
    required this.currency,
    required this.readOnly,
    required this.onAddItem,
    required this.onEdit,
  });

  final MealModel meal;
  final String currency;
  final bool readOnly;
  final VoidCallback onAddItem;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(itemsByMealProvider(meal.id));
    final money = ref.watch(mealMoneyProvider(meal));
    final int year =
        ref.watch(selectedPlanProvider).asData?.value.year ??
        ref.watch(currentYearProvider);
    final guests = meal.hasGuests
        ? '${meal.guestCount} ${meal.guestCount == 1 ? 'guest' : 'guests'}'
        : 'Guests not set';

    Future<void> forward(MealItemModel item, MealItemStatus to) async {
      final controller = ref.read(mealControllerProvider);
      try {
        final previous = await controller.setStatus(item, to);
        if (!context.mounted) return;
        showUndoSnackBar(
          context,
          message: '${item.itemName} marked ${to.value}.',
          onUndo: () => controller.restore(previous),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Couldn't update ${item.itemName}.")),
          );
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.md),
          child: Row(
            children: [
              Icon(
                Icons.group_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Space.sm),
              Text(
                '${formatDayMonth(meal.type.dateIn(year))} · $guests',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          child: MoneyTripleView(
            money: money,
            currency: currency,
            onSetBudget: readOnly ? null : onEdit,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          child: SectionHeader(
            title: 'Menu',
            trailing: money.plannedCount == 0
                ? null
                : '${money.purchasedCount} of ${money.plannedCount} bought',
          ),
        ),
        asyncList(
          items,
          errorMessage: "Couldn't load the menu.",
          onRetry: () => ref.invalidate(ensuredPlanProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  message: 'Nothing on the menu yet.',
                  actionLabel: readOnly ? null : 'Add item',
                  onAction: readOnly ? null : onAddItem,
                )
              : Column(
                  children: [
                    const Divider(),
                    for (final i in list) ...[
                      MenuItemRow(
                        item: i,
                        currency: currency,
                        enabled: !readOnly,
                        onTap: readOnly
                            ? () {}
                            : () => showMealItemForm(
                                context,
                                meal: meal,
                                money: money,
                                currency: currency,
                                item: i,
                              ),
                        onForward: readOnly ? null : (to) => forward(i, to),
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
