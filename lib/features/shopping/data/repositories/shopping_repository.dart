import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/shopping_list_model.dart';

class ShoppingRepository {
  final SupabaseClient _supabase;

  ShoppingRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<ShoppingListModel>> getShoppingLists() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('shopping_lists')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('name', ascending: true);

      final lists = (response as List)
          .map((json) => ShoppingListModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${lists.length} shopping lists');
      return lists;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch shopping lists', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching shopping lists', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch shopping lists', error: e);
    }
  }

  Future<ShoppingListModel?> getDefaultShoppingList() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('shopping_lists')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ShoppingListModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch default shopping list', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching default shopping list', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch default shopping list', error: e);
    }
  }

  Future<ShoppingListModel> createShoppingList(ShoppingListModel list) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final listData = list.toInsertJson();
      listData['user_id'] = userId;

      final response = await _supabase
          .from('shopping_lists')
          .insert(listData)
          .select()
          .single();

      final created = ShoppingListModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created shopping list: ${created.name}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create shopping list', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating shopping list', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create shopping list', error: e);
    }
  }

  Future<ShoppingListModel> updateShoppingList(ShoppingListModel list) async {
    try {
      final response = await _supabase
          .from('shopping_lists')
          .update(list.toInsertJson())
          .eq('id', list.id)
          .select()
          .single();

      final updated = ShoppingListModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated shopping list: ${updated.name}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update shopping list', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating shopping list', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update shopping list', error: e);
    }
  }

  Future<void> deleteShoppingList(String id) async {
    try {
      await _supabase
          .from('shopping_lists')
          .delete()
          .eq('id', id);

      AppLogger.info('Deleted shopping list: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete shopping list', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting shopping list', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete shopping list', error: e);
    }
  }

  Future<List<ShoppingListItemModel>> getShoppingListItems(String listId) async {
    try {
      final response = await _supabase
          .from('shopping_list_items')
          .select()
          .eq('shopping_list_id', listId)
          .order('purchased', ascending: true)
          .order('category', ascending: true)
          .order('item_name', ascending: true);

      final items = (response as List)
          .map((json) => ShoppingListItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${items.length} shopping list items');
      return items;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch shopping list items', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching shopping list items', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch shopping list items', error: e);
    }
  }

  Future<ShoppingListItemModel> createShoppingListItem(ShoppingListItemModel item) async {
    try {
      final response = await _supabase
          .from('shopping_list_items')
          .insert(item.toInsertJson())
          .select()
          .single();

      final created = ShoppingListItemModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created shopping list item: ${created.itemName}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create shopping list item', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating shopping list item', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create shopping list item', error: e);
    }
  }

  Future<ShoppingListItemModel> updateShoppingListItem(ShoppingListItemModel item) async {
    try {
      final response = await _supabase
          .from('shopping_list_items')
          .update(item.toInsertJson())
          .eq('id', item.id)
          .select()
          .single();

      final updated = ShoppingListItemModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated shopping list item: ${updated.itemName}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update shopping list item', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating shopping list item', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update shopping list item', error: e);
    }
  }

  Future<void> deleteShoppingListItem(String id) async {
    try {
      await _supabase
          .from('shopping_list_items')
          .delete()
          .eq('id', id);

      AppLogger.info('Deleted shopping list item: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete shopping list item', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting shopping list item', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete shopping list item', error: e);
    }
  }

  Future<void> toggleItemPurchased(String itemId, bool purchased) async {
    try {
      await _supabase
          .from('shopping_list_items')
          .update({
            'purchased': purchased,
            'purchased_date': purchased ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', itemId);

      AppLogger.info('Toggled item purchased: $itemId');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to toggle item purchased', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error toggling item purchased', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to toggle item purchased', error: e);
    }
  }

  Stream<List<ShoppingListModel>> watchShoppingLists() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.error(const AuthenticationException(message: 'User not authenticated'));
    }

    return _supabase
        .from('shopping_lists')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('name', ascending: true)
        .map((data) => data.map((json) => ShoppingListModel.fromJson(json)).toList());
  }

  Stream<List<ShoppingListItemModel>> watchShoppingListItems(String listId) {
    return _supabase
        .from('shopping_list_items')
        .stream(primaryKey: ['id'])
        .eq('shopping_list_id', listId)
        .order('purchased', ascending: true)
        .order('category', ascending: true)
        .order('item_name', ascending: true)
        .map((data) => data.map((json) => ShoppingListItemModel.fromJson(json)).toList());
  }

  Future<Map<String, dynamic>> getShoppingListStats(String listId) async {
    try {
      final items = await getShoppingListItems(listId);

      final totalItems = items.length;
      final purchasedItems = items.where((item) => item.purchased).length;
      final estimatedTotal = items.fold<double>(0.0, (sum, item) => sum + (item.estimatedCost ?? 0.0));
      final actualTotal = items.where((item) => item.purchased).fold<double>(0.0, (sum, item) => sum + (item.actualCost ?? item.estimatedCost ?? 0.0));

      return {
        'totalItems': totalItems,
        'purchasedItems': purchasedItems,
        'remainingItems': totalItems - purchasedItems,
        'completionPercentage': totalItems > 0 ? (purchasedItems / totalItems) * 100 : 0.0,
        'estimatedTotal': estimatedTotal,
        'actualTotal': actualTotal,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate shopping list stats', error: e, stackTrace: stackTrace);
      return {
        'totalItems': 0,
        'purchasedItems': 0,
        'remainingItems': 0,
        'completionPercentage': 0.0,
        'estimatedTotal': 0.0,
        'actualTotal': 0.0,
      };
    }
  }
}
