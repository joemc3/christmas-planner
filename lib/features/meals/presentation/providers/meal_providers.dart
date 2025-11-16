import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/meal_item_model.dart';
import '../../data/repositories/meal_repository.dart';

// Repository Provider
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository();
});

// Meals Stream Provider
final mealsStreamProvider = StreamProvider<List<MealModel>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.watchMeals();
});

// Meal by ID Provider
final mealByIdProvider = FutureProvider.family<MealModel?, String>((ref, id) async {
  final repo = ref.watch(mealRepositoryProvider);
  return await repo.getMealById(id);
});

// Meal Items Stream Provider
final mealItemsStreamProvider = StreamProvider.family<List<MealItemModel>, String>((ref, mealId) {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.watchMealItems(mealId);
});

// Meal Budget Stats Provider
final mealBudgetStatsProvider = FutureProvider.family<Map<String, double>, String>((ref, mealId) async {
  final repo = ref.watch(mealRepositoryProvider);
  return await repo.calculateMealBudgetStats(mealId);
});

// Meal Controller
final mealControllerProvider = Provider<MealController>((ref) {
  return MealController(ref.read(mealRepositoryProvider));
});

class MealController {
  final MealRepository _repository;

  MealController(this._repository);

  Future<MealModel> createMeal(MealModel meal) async {
    try {
      return await _repository.createMeal(meal);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create meal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<MealModel> updateMeal(MealModel meal) async {
    try {
      return await _repository.updateMeal(meal);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update meal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await _repository.deleteMeal(id);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete meal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<MealItemModel> createMealItem(MealItemModel item) async {
    try {
      return await _repository.createMealItem(item);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create meal item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<MealItemModel> updateMealItem(MealItemModel item) async {
    try {
      return await _repository.updateMealItem(item);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update meal item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteMealItem(String id) async {
    try {
      await _repository.deleteMealItem(id);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete meal item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
