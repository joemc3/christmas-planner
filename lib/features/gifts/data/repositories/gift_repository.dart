import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final SupabaseClient _supabase;

  GiftRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<GiftModel>> getGifts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('gifts')
          .select('*, recipients!inner(user_id)')
          .eq('recipients.user_id', userId)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      final gifts = (response as List)
          .map((json) {
            final giftJson = Map<String, dynamic>.from(json as Map);
            giftJson.remove('recipients');
            return GiftModel.fromJson(giftJson);
          })
          .toList();

      AppLogger.info('Fetched ${gifts.length} gifts');
      return gifts;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch gifts', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching gifts', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch gifts', error: e);
    }
  }

  Future<List<GiftModel>> getGiftsByRecipient(String recipientId) async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .eq('recipient_id', recipientId)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      final gifts = (response as List)
          .map((json) => GiftModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${gifts.length} gifts for recipient $recipientId');
      return gifts;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch gifts by recipient', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching gifts by recipient', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch gifts by recipient', error: e);
    }
  }

  Future<GiftModel?> getGiftById(String id) async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return GiftModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch gift', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching gift', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch gift', error: e);
    }
  }

  Future<GiftModel> createGift(GiftModel gift) async {
    try {
      final response = await _supabase
          .from('gifts')
          .insert(gift.toInsertJson())
          .select()
          .single();

      final created = GiftModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created gift: ${created.name}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create gift', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating gift', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create gift', error: e);
    }
  }

  Future<GiftModel> updateGift(GiftModel gift) async {
    try {
      final response = await _supabase
          .from('gifts')
          .update(gift.toInsertJson())
          .eq('id', gift.id)
          .select()
          .single();

      final updated = GiftModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated gift: ${updated.name}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update gift', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating gift', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update gift', error: e);
    }
  }

  Future<void> deleteGift(String id) async {
    try {
      await _supabase
          .from('gifts')
          .delete()
          .eq('id', id);

      AppLogger.info('Deleted gift: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete gift', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting gift', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete gift', error: e);
    }
  }

  Future<void> updateGiftStatus(String id, GiftStatus status) async {
    try {
      await _supabase
          .from('gifts')
          .update({'status': status.value})
          .eq('id', id);

      AppLogger.info('Updated gift status: $id to ${status.value}');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update gift status', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating gift status', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update gift status', error: e);
    }
  }

  Stream<List<GiftModel>> watchGiftsByRecipient(String recipientId) {
    return _supabase
        .from('gifts')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', recipientId)
        .order('priority', ascending: false)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => GiftModel.fromJson(json)).toList());
  }

  Stream<List<GiftModel>> watchAllGifts() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.error(const AuthenticationException(message: 'User not authenticated'));
    }

    // Note: Streaming with joins is limited in Supabase, so we fetch all gifts
    // and filter client-side or use RPC functions
    return _supabase
        .from('gifts')
        .stream(primaryKey: ['id'])
        .order('priority', ascending: false)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => GiftModel.fromJson(json)).toList());
  }

  Future<Map<String, double>> calculateGiftBudgetStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final gifts = await getGifts();

      double totalSpent = 0.0;
      double totalPlanned = 0.0;

      for (final gift in gifts) {
        totalPlanned += gift.price;
        if (gift.status == GiftStatus.ordered ||
            gift.status == GiftStatus.purchased ||
            gift.status == GiftStatus.wrapped ||
            gift.status == GiftStatus.delivered) {
          totalSpent += gift.effectivePrice;
        }
      }

      return {
        'totalSpent': totalSpent,
        'totalPlanned': totalPlanned,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate gift budget stats', error: e, stackTrace: stackTrace);
      return {
        'totalSpent': 0.0,
        'totalPlanned': 0.0,
      };
    }
  }
}
