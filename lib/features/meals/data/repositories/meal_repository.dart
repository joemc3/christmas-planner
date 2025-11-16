import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/meal_model.dart';
import '../models/meal_item_model.dart';

class MealRepository {
  final SupabaseClient _supabase;

  MealRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<MealModel>> getMeals({int? year}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      var query = _supabase
          .from('meals')
          .select()
          .eq('user_id', userId)
          .order('type', ascending: true);

      if (year != null) {
        query = query.eq('year', year);
      }

      final response = await query;
      final meals = (response as List)
          .map((json) => MealModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${meals.length} meals');
      return meals;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch meals', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching meals', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch meals', error: e);
    }
  }

  Future<MealModel?> getMealById(String id) async {
    try {
      final response = await _supabase
          .from('meals')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return MealModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch meal', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching meal', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch meal', error: e);
    }
  }

  Future<MealModel> createMeal(MealModel meal) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final mealData = meal.toInsertJson();
      mealData['user_id'] = userId;

      final response = await _supabase
          .from('meals')
          .insert(mealData)
          .select()
          .single();

      final created = MealModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created meal: ${created.name}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create meal', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating meal', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create meal', error: e);
    }
  }

  Future<MealModel> updateMeal(MealModel meal) async {
    try {
      final response = await _supabase
          .from('meals')
          .update(meal.toInsertJson())
          .eq('id', meal.id)
          .select()
          .single();

      final updated = MealModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated meal: ${updated.name}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update meal', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating meal', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update meal', error: e);
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await _supabase
          .from('meals')
          .delete()
          .eq('id', id);

      AppLogger.info('Deleted meal: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete meal', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting meal', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete meal', error: e);
    }
  }

  Future<List<MealItemModel>> getMealItems(String mealId) async {
    try {
      final response = await _supabase
          .from('meal_items')
          .select()
          .eq('meal_id', mealId)
          .order('category', ascending: true)
          .order('item_name', ascending: true);

      final items = (response as List)
          .map((json) => MealItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${items.length} meal items for meal $mealId');
      return items;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch meal items', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching meal items', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch meal items', error: e);
    }
  }

  Future<MealItemModel> createMealItem(MealItemModel item) async {
    try {
      final response = await _supabase
          .from('meal_items')
          .insert(item.toInsertJson())
          .select()
          .single();

      final created = MealItemModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created meal item: ${created.itemName}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create meal item', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating meal item', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create meal item', error: e);
    }
  }

  Future<MealItemModel> updateMealItem(MealItemModel item) async {
    try {
      final response = await _supabase
          .from('meal_items')
          .update(item.toInsertJson())
          .eq('id', item.id)
          .select()
          .single();

      final updated = MealItemModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated meal item: ${updated.itemName}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update meal item', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating meal item', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update meal item', error: e);
    }
  }

  Future<void> deleteMealItem(String id) async {
    try {
      await _supabase
          .from('meal_items')
          .delete()
          .eq('id', id);

      AppLogger.info('Deleted meal item: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete meal item', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting meal item', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete meal item', error: e);
    }
  }

  Stream<List<MealModel>> watchMeals({int? year}) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.error(const AuthenticationException(message: 'User not authenticated'));
    }

    var query = _supabase
        .from('meals')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('type', ascending: true);

    return query.map((data) {
      var meals = data.map((json) => MealModel.fromJson(json)).toList();
      if (year != null) {
        meals = meals.where((m) => m.year == year).toList();
      }
      return meals;
    });
  }

  Stream<List<MealItemModel>> watchMealItems(String mealId) {
    return _supabase
        .from('meal_items')
        .stream(primaryKey: ['id'])
        .eq('meal_id', mealId)
        .order('category', ascending: true)
        .order('item_name', ascending: true)
        .map((data) => data.map((json) => MealItemModel.fromJson(json)).toList());
  }

  Future<Map<String, double>> calculateMealBudgetStats(String mealId) async {
    try {
      final items = await getMealItems(mealId);

      double totalSpent = 0.0;
      double totalPlanned = 0.0;

      for (final item in items) {
        totalPlanned += item.cost;
        if (item.status == MealItemStatus.purchased ||
            item.status == MealItemStatus.prepared) {
          totalSpent += item.effectiveCost;
        }
      }

      return {
        'totalSpent': totalSpent,
        'totalPlanned': totalPlanned,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate meal budget stats', error: e, stackTrace: stackTrace);
      return {
        'totalSpent': 0.0,
        'totalPlanned': 0.0,
      };
    }
  }
}
