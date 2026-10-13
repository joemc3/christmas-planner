import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/meal_model.dart';
import '../providers/meal_providers.dart';
import '../widgets/meal_form_sheet.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  Future<void> _addMeal(BuildContext context, {MealType? type}) async {
    final created = await MealFormSheet.show(context, initialType: type);
    if (created != null && context.mounted) {
      await context.push('/meals/${created.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealsStreamProvider);
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: Text('Meals $year')),
      body: mealsAsync.when(
        data: (allMeals) {
          final meals = allMeals.where((m) => m.year == year).toList();
          if (meals.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                const EmptyState(
                  icon: Icons.restaurant,
                  title: 'Nothing on the menu yet',
                  subtitle:
                      'Plan each meal: who is coming, what you are serving, '
                      'what it costs and who brings what.',
                ),
                _StarterCard(
                  title: 'Christmas Eve dinner',
                  icon: Icons.nightlight_round,
                  onTap: () => _addMeal(context, type: MealType.xmasEve),
                ),
                const SizedBox(height: 12),
                _StarterCard(
                  title: 'Christmas Day lunch',
                  icon: Icons.wb_sunny_outlined,
                  onTap: () => _addMeal(context, type: MealType.xmasDay),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final meal in meals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealCard(
                    meal: meal,
                    onTap: () => context.push('/meals/${meal.id}'),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load meals',
          subtitle: error.toString(),
          actionText: 'Retry',
          onAction: () => ref.invalidate(mealsStreamProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMeal(context),
        icon: const Icon(Icons.add),
        label: const Text('Meal'),
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _StarterCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: FrostedHearthColors.ember),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Plan $title',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Icon(Icons.add, color: FrostedHearthColors.inkLight),
        ],
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  final MealModel meal;
  final VoidCallback onTap;

  const _MealCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(mealBudgetStatsProvider(meal.id)).value;
    final planned = stats?['totalPlanned'] ?? 0.0;
    final over = meal.budgetLimit > 0 && planned > meal.budgetLimit;

    return FrostedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                meal.type == MealType.xmasEve
                    ? Icons.nightlight_round
                    : meal.type == MealType.xmasDay
                    ? Icons.wb_sunny_outlined
                    : Icons.restaurant_outlined,
                color: FrostedHearthColors.ember,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meal.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: FrostedHearthColors.inkLight,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            [
              meal.type.displayName,
              if (meal.mealTime != null) AppDateUtils.formatTime(meal.mealTime),
              if (meal.location != null) meal.location!,
              '${meal.guestCount} guest${meal.guestCount == 1 ? '' : 's'}',
            ].join(' · '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                meal.budgetLimit > 0
                    ? '${AppDateUtils.formatCurrency(planned)} of '
                          '${AppDateUtils.formatCurrency(meal.budgetLimit)}'
                    : '${AppDateUtils.formatCurrency(planned)} planned',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: over ? FrostedHearthColors.error : null,
                ),
              ),
              if (meal.dietaryRestrictions.isNotEmpty) ...[
                const Spacer(),
                Text(
                  meal.dietaryRestrictions.join(', '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
