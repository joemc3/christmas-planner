import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/money.dart';
import '../../../../core/layout/breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/widgets/states.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/meal_model.dart';
import '../providers/meal_providers.dart';
import '../widgets/meal_forms.dart';
import '../widgets/rows.dart';
import 'meal_screen.dart';

final selectedMealIdProvider = NotifierProvider<_Selected, String?>(
  _Selected.new,
);

class _Selected extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

/// B5: exactly two rows, no add and no delete.
class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    final expanded = WindowSize.of(context).isExpanded;

    final list = Scaffold(
      appBar: AppBar(title: const Text('Meals')),
      body: asyncList(
        meals,
        errorMessage: "Couldn't load the meals.",
        onRetry: () => ref.invalidate(ensuredPlanProvider),
        skeletonCount: 2,
        data: (list) => _MealList(meals: list, expanded: expanded),
      ),
    );

    if (!expanded) return list;

    final selectedId = ref.watch(selectedMealIdProvider);
    return Row(
      children: [
        SizedBox(width: 420, child: list),
        const VerticalDivider(),
        Expanded(
          child: selectedId == null
              ? const Center(child: Text('Choose a meal'))
              : MealScreen(mealId: selectedId, embedded: true),
        ),
      ],
    );
  }
}

class _MealList extends ConsumerWidget {
  const _MealList({required this.meals, required this.expanded});
  final List<MealModel> meals;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency =
        ref.watch(userProfileProvider).asData?.value?.currency ?? 'USD';
    final int year =
        ref.watch(selectedPlanProvider).asData?.value.year ??
        ref.watch(currentYearProvider);
    final readOnly = ref.watch(readOnlyProvider);
    final selectedId = ref.watch(selectedMealIdProvider);
    final moneys = {
      for (final m in meals) m.id: ref.watch(mealMoneyProvider(m)),
    };
    final total = sumMoney(moneys.values);

    return ListView(
      children: [
        if (total.hasBudget)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
            child: RichText(
              text: TextSpan(
                style: tabular(theme.textTheme.bodyMedium),
                children: [
                  TextSpan(
                    text: total.isOverBudget
                        ? '${formatMoney(total.overBy, currency: currency)} over'
                        : formatMoney(total.remaining, currency: currency),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: total.isOverBudget
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' ${total.isOverBudget ? 'budget' : 'left of'} '
                        '${formatMoney(total.budget, currency: currency)} · '
                        'Eve and Day together',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        const Divider(),
        for (final m in meals) ...[
          MealRow(
            meal: m,
            money: moneys[m.id]!,
            currency: currency,
            year: year,
            selected: expanded && selectedId == m.id,
            onSetBudget: readOnly
                ? null
                : () => showMealForm(
                    context,
                    meal: m,
                    money: moneys[m.id]!,
                    currency: currency,
                  ),
            onTap: () {
              if (expanded) {
                ref.read(selectedMealIdProvider.notifier).select(m.id);
              } else {
                context.go('/meals/${m.id}');
              }
            },
          ),
          const Divider(),
        ],
      ],
    );
  }
}
