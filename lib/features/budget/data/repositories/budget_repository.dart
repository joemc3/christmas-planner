import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/family_budget_model.dart';

class BudgetRepository {
  final SupabaseClient _supabase;

  BudgetRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<FamilyBudgetModel?> getCurrentYearBudget() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final currentYear = DateTime.now().year;

      final response = await _supabase
          .from('family_budgets')
          .select()
          .eq('user_id', userId)
          .eq('year', currentYear)
          .maybeSingle();

      if (response == null) {
        // Create default budget for current year
        return await createBudget(FamilyBudgetModel(
          id: '',
          userId: userId,
          giftBudgetTotal: 1000.0,
          mealBudgetEve: 300.0,
          mealBudgetDay: 500.0,
          year: currentYear,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final budget = FamilyBudgetModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Fetched budget for year $currentYear');
      return budget;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch budget', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching budget', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch budget', error: e);
    }
  }

  Future<List<FamilyBudgetModel>> getAllBudgets() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('family_budgets')
          .select()
          .eq('user_id', userId)
          .order('year', ascending: false);

      final budgets = (response as List)
          .map((json) => FamilyBudgetModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${budgets.length} budgets');
      return budgets;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch budgets', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching budgets', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch budgets', error: e);
    }
  }

  Future<FamilyBudgetModel> createBudget(FamilyBudgetModel budget) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final budgetData = budget.toInsertJson();
      budgetData['user_id'] = userId;

      final response = await _supabase
          .from('family_budgets')
          .insert(budgetData)
          .select()
          .single();

      final created = FamilyBudgetModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created budget for year ${created.year}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create budget', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating budget', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create budget', error: e);
    }
  }

  Future<FamilyBudgetModel> updateBudget(FamilyBudgetModel budget) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('family_budgets')
          .update(budget.toInsertJson())
          .eq('id', budget.id)
          .eq('user_id', userId)
          .select()
          .single();

      final updated = FamilyBudgetModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated budget for year ${updated.year}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update budget', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating budget', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update budget', error: e);
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      await _supabase
          .from('family_budgets')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      AppLogger.info('Deleted budget: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete budget', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting budget', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete budget', error: e);
    }
  }

  Stream<FamilyBudgetModel?> watchCurrentYearBudget() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.error(const AuthenticationException(message: 'User not authenticated'));
    }

    final currentYear = DateTime.now().year;

    return _supabase
        .from('family_budgets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .eq('year', currentYear)
        .map((data) {
          if (data.isEmpty) return null;
          return FamilyBudgetModel.fromJson(data.first);
        });
  }

  Future<Map<String, dynamic>> calculateOverallBudgetStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      // Get gift spending
      final giftsResponse = await _supabase
          .from('gifts')
          .select('price, actual_price, status, recipients!inner(user_id)')
          .eq('recipients.user_id', userId);

      double giftSpent = 0.0;
      for (final gift in giftsResponse as List) {
        final status = gift['status'] as String;
        if (status == 'Ordered' || status == 'Purchased' || status == 'Wrapped' || status == 'Delivered') {
          final actualPrice = gift['actual_price'] as double?;
          final price = gift['price'] as double;
          giftSpent += actualPrice ?? price;
        }
      }

      // Get meal spending
      final mealsResponse = await _supabase
          .from('meal_items')
          .select('cost, actual_cost, status, meals!inner(user_id)')
          .eq('meals.user_id', userId);

      double mealSpent = 0.0;
      for (final item in mealsResponse as List) {
        final status = item['status'] as String;
        if (status == 'Purchased' || status == 'Prepared') {
          final actualCost = item['actual_cost'] as double?;
          final cost = item['cost'] as double;
          mealSpent += actualCost ?? cost;
        }
      }

      // Get expenses
      final expensesResponse = await _supabase
          .from('expenses')
          .select('amount, category')
          .eq('user_id', userId);

      double decorationsSpent = 0.0;
      double activitiesSpent = 0.0;
      double miscellaneousSpent = 0.0;

      for (final expense in expensesResponse as List) {
        final amount = expense['amount'] as double;
        final category = expense['category'] as String;

        switch (category.toLowerCase()) {
          case 'decorations':
            decorationsSpent += amount;
            break;
          case 'activities':
            activitiesSpent += amount;
            break;
          default:
            miscellaneousSpent += amount;
        }
      }

      return {
        'giftSpent': giftSpent,
        'mealSpent': mealSpent,
        'decorationsSpent': decorationsSpent,
        'activitiesSpent': activitiesSpent,
        'miscellaneousSpent': miscellaneousSpent,
        'totalSpent': giftSpent + mealSpent + decorationsSpent + activitiesSpent + miscellaneousSpent,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate budget stats', error: e, stackTrace: stackTrace);
      return {
        'giftSpent': 0.0,
        'mealSpent': 0.0,
        'decorationsSpent': 0.0,
        'activitiesSpent': 0.0,
        'miscellaneousSpent': 0.0,
        'totalSpent': 0.0,
      };
    }
  }
}
