import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/money.dart';
import '../../../plan/presentation/providers/plan_providers.dart';
import '../../data/models/meal_item_model.dart';
import '../../data/models/meal_model.dart';
import '../../data/repositories/meal_repository.dart';

final mealRepositoryProvider = Provider<MealRepository>(
  (ref) => MealRepository(),
);

/// The selected plan's two meals, Eve then Day. Live.
final mealsProvider = Provider<AsyncValue<List<MealModel>>>((ref) {
  final plan = ref.watch(selectedPlanProvider);
  return plan.when(
    data: (p) => ref.watch(_mealsOfPlanProvider(p.id)),
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
  );
});

final _mealsOfPlanProvider = StreamProvider.family<List<MealModel>, String>(
  (ref, planId) => ref.watch(mealRepositoryProvider).watchMeals(planId),
);

final _allItemsProvider = StreamProvider<List<MealItemModel>>(
  (ref) => ref.watch(mealRepositoryProvider).watchAllMealItems(),
);

/// Menu items of the selected plan's meals.
final mealItemsProvider = Provider<AsyncValue<List<MealItemModel>>>((ref) {
  final meals = ref.watch(mealsProvider);
  final items = ref.watch(_allItemsProvider);
  if (meals.hasError) return AsyncError(meals.error!, StackTrace.current);
  if (items.hasError) return AsyncError(items.error!, StackTrace.current);
  final m = meals.asData?.value;
  final i = items.asData?.value;
  if (m == null || i == null) return const AsyncLoading();
  final ids = {for (final x in m) x.id};
  return AsyncData([
    for (final item in i)
      if (ids.contains(item.mealId)) item,
  ]);
});

final itemsByMealProvider =
    Provider.family<AsyncValue<List<MealItemModel>>, String>(
      (ref, mealId) => ref
          .watch(mealItemsProvider)
          .whenData(
            (all) => [
              for (final i in all)
                if (i.mealId == mealId) i,
            ],
          ),
    );

final mealByIdProvider = Provider.family<AsyncValue<MealModel?>, String>(
  (ref, id) => ref.watch(mealsProvider).whenData((all) {
    final found = all.where((m) => m.id == id);
    return found.isEmpty ? null : found.first;
  }),
);

final mealMoneyProvider = Provider.family<MoneyTriple, MealModel>((ref, meal) {
  final items = ref.watch(itemsByMealProvider(meal.id)).asData?.value;
  return mealMoney(items ?? const [], budget: meal.budgetLimit);
});

final mealControllerProvider = Provider<MealController>(
  (ref) => MealController(ref),
);

class MealController {
  MealController(this._ref);
  final Ref _ref;
  MealRepository get _repo => _ref.read(mealRepositoryProvider);

  Future<MealModel> updateMeal(MealModel m) => _repo.updateMeal(m);

  Future<MealItemModel> createItem(MealItemModel i) => _repo.createMealItem(i);

  Future<MealItemModel> updateItem(MealItemModel i) => _repo.updateMealItem(i);

  Future<void> deleteItem(String id) => _repo.deleteMealItem(id);

  /// Returns the item as it was, for Undo.
  Future<MealItemModel> setStatus(MealItemModel item, MealItemStatus to) async {
    await _repo.updateMealItem(item.copyWith(status: to));
    return item;
  }

  Future<void> restore(MealItemModel previous) =>
      _repo.updateMealItem(previous);
}
