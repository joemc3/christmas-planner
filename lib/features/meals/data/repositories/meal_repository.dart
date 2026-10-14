import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/guard.dart';
import '../models/meal_item_model.dart';
import '../models/meal_model.dart';

class MealRepository {
  MealRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// The plan's two meals, Eve then Day. Live.
  Stream<List<MealModel>> watchMeals(String planId) => _supabase
      .from('meals')
      .stream(primaryKey: ['id'])
      .eq('plan_id', planId)
      .map((rows) {
        final meals = rows.map(MealModel.fromJson).toList()
          ..sort((a, b) => a.type.index.compareTo(b.type.index));
        return meals;
      });

  Future<MealModel?> getMealById(String id) => guard('fetch meal', () async {
    final row = await _supabase
        .from('meals')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : MealModel.fromJson(row);
  });

  /// Guests and budget are the only editable fields (PRD MEAL-1).
  Future<MealModel> updateMeal(MealModel meal) => guard('update meal', () async {
    final row = await _supabase
        .from('meals')
        .update(meal.toUpdateJson())
        .eq('id', meal.id)
        .select()
        .single();
    return MealModel.fromJson(row);
  });

  /// Every menu item the user can see. Live; callers group by meal.
  Stream<List<MealItemModel>> watchAllMealItems() => _supabase
      .from('meal_items')
      .stream(primaryKey: ['id'])
      .order('item_name', ascending: true)
      .map((rows) => rows.map(MealItemModel.fromJson).toList());

  Future<MealItemModel> createMealItem(MealItemModel item) =>
      guard('create menu item', () async {
        final row = await _supabase
            .from('meal_items')
            .insert(item.toInsertJson())
            .select()
            .single();
        return MealItemModel.fromJson(row);
      });

  Future<MealItemModel> updateMealItem(MealItemModel item) =>
      guard('update menu item', () async {
        final row = await _supabase
            .from('meal_items')
            .update(item.toInsertJson())
            .eq('id', item.id)
            .select()
            .single();
        return MealItemModel.fromJson(row);
      });

  Future<void> deleteMealItem(String id) => guard('delete menu item', () async {
    await _supabase.from('meal_items').delete().eq('id', id);
  });
}
