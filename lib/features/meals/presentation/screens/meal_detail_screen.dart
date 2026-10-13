import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/meal_item_model.dart';
import '../../data/models/meal_model.dart';
import '../providers/meal_providers.dart';
import '../widgets/meal_form_sheet.dart';
import '../widgets/meal_item_form_sheet.dart';

class MealDetailScreen extends ConsumerWidget {
  final String mealId;

  const MealDetailScreen({super.key, required this.mealId});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MealModel meal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete ${meal.name}?',
        message: 'The whole menu for this meal will be removed.',
        confirmText: 'Delete',
        isDestructive: true,
        icon: Icons.delete_outline,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(mealControllerProvider).deleteMeal(meal.id);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  Future<void> _cycleStatus(
    BuildContext context,
    WidgetRef ref,
    MealItemModel item,
  ) async {
    final next = switch (item.status) {
      MealItemStatus.toBuy => MealItemStatus.purchased,
      MealItemStatus.purchased => MealItemStatus.prepared,
      MealItemStatus.prepared => MealItemStatus.toBuy,
    };
    try {
      await ref
          .read(mealControllerProvider)
          .updateMealItem(item.copyWith(status: next));
      ref.invalidate(mealBudgetStatsProvider(item.mealId));
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    MealItemModel item,
  ) async {
    try {
      await ref.read(mealControllerProvider).deleteMealItem(item.id);
      ref.invalidate(mealBudgetStatsProvider(item.mealId));
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealAsync = ref.watch(mealByIdProvider(mealId));
    final itemsAsync = ref.watch(mealItemsStreamProvider(mealId));

    return mealAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (meal) {
        if (meal == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.no_meals,
              title: 'Meal not found',
            ),
          );
        }
        final items = itemsAsync.value ?? const <MealItemModel>[];
        return Scaffold(
          appBar: AppBar(
            title: Text(meal.name),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => MealFormSheet.show(context, existing: meal),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref, meal),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            children: [
              _MealHeader(meal: meal, items: items),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Menu',
                actionText: 'Add item',
                onAction: () =>
                    MealItemFormSheet.show(context, mealId: meal.id),
              ),
              itemsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Error: $e'),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.restaurant_menu,
                      title: 'Menu is empty',
                      subtitle:
                          'Add dishes and ingredients. Tap an item to mark it '
                          'bought or prepared.',
                      actionText: 'Add item',
                      onAction: () =>
                          MealItemFormSheet.show(context, mealId: meal.id),
                    );
                  }
                  final byCourse = <String, List<MealItemModel>>{};
                  for (final i in items) {
                    byCourse
                        .putIfAbsent(i.category ?? 'Other', () => [])
                        .add(i);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in byCourse.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: FrostedHearthColors.inkMedium,
                                ),
                          ),
                        ),
                        for (final item in entry.value)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _MealItemTile(
                              item: item,
                              onToggle: () => _cycleStatus(context, ref, item),
                              onEdit: () => MealItemFormSheet.show(
                                context,
                                mealId: meal.id,
                                existing: item,
                              ),
                              onDelete: () => _deleteItem(context, ref, item),
                            ),
                          ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: FloatingActionButton.extended(
              onPressed: () => MealItemFormSheet.show(context, mealId: meal.id),
              icon: const Icon(Icons.add),
              label: const Text('Item'),
            ),
          ),
        );
      },
    );
  }
}

class _MealHeader extends StatelessWidget {
  final MealModel meal;
  final List<MealItemModel> items;

  const _MealHeader({required this.meal, required this.items});

  @override
  Widget build(BuildContext context) {
    final planned = items.fold<double>(0, (s, i) => s + i.effectiveCost);
    final spent = items
        .where((i) => i.status != MealItemStatus.toBuy)
        .fold<double>(0, (s, i) => s + i.effectiveCost);
    final ready = items
        .where((i) => i.status == MealItemStatus.prepared)
        .length;
    final totalMinutes = items.fold<int>(0, (s, i) => s + i.totalTime);
    final budget = meal.budgetLimit;

    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              meal.type.displayName,
              if (meal.mealTime != null) AppDateUtils.formatTime(meal.mealTime),
              if (meal.location != null) meal.location!,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (meal.theme != null) ...[
            const SizedBox(height: 4),
            Text(meal.theme!, style: Theme.of(context).textTheme.titleMedium),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  'Guests',
                  '${meal.guestCount}',
                  icon: Icons.people_outline,
                ),
              ),
              Expanded(
                child: _Stat(
                  'Budget',
                  budget > 0 ? AppDateUtils.formatCurrency(budget) : 'not set',
                ),
              ),
              Expanded(
                child: _Stat(
                  'Planned',
                  AppDateUtils.formatCurrency(planned),
                  color: budget > 0 && planned > budget
                      ? FrostedHearthColors.error
                      : null,
                ),
              ),
              Expanded(
                child: _Stat('Spent', AppDateUtils.formatCurrency(spent)),
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
          const SizedBox(height: 12),
          Text(
            [
              '$ready of ${items.length} prepared',
              if (totalMinutes > 0)
                '${totalMinutes ~/ 60}h ${totalMinutes % 60}m total prep & cook',
              if (meal.dietaryRestrictions.isNotEmpty)
                meal.dietaryRestrictions.join(', '),
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (meal.notes != null && meal.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(meal.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const _Stat(this.label, this.value, {this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MealItemTile extends StatelessWidget {
  final MealItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MealItemTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.status) {
      MealItemStatus.toBuy => (
        Icons.radio_button_unchecked,
        FrostedHearthColors.inkLight,
      ),
      MealItemStatus.purchased => (
        Icons.shopping_bag_outlined,
        FrostedHearthColors.ember,
      ),
      MealItemStatus.prepared => (
        Icons.check_circle,
        FrostedHearthColors.success,
      ),
    };

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: FrostedHearthColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: FrostedCard(
        onTap: onEdit,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Status: ${item.status.value} (tap to change)',
              icon: Icon(icon, color: color),
              onPressed: onToggle,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: item.status == MealItemStatus.prepared
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [
                      if (item.quantity != null) item.quantity!,
                      if (item.assignedTo != null) item.assignedTo!,
                      if (item.totalTime > 0) '${item.totalTime} min',
                      if (item.storeName != null) item.storeName!,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                AppDateUtils.formatCurrency(item.effectiveCost),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
