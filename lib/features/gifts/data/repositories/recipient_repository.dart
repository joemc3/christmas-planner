import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/recipient_model.dart';

class RecipientRepository {
  final SupabaseClient _supabase;

  RecipientRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<RecipientModel>> getRecipients({bool includeArchived = false}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      var query = _supabase
          .from('recipients')
          .select()
          .eq('user_id', userId)
          .order('priority', ascending: false)
          .order('name', ascending: true);

      if (!includeArchived) {
        query = query.eq('archived', false);
      }

      final response = await query;
      final recipients = (response as List)
          .map((json) => RecipientModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${recipients.length} recipients');
      return recipients;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch recipients', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching recipients', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch recipients', error: e);
    }
  }

  Future<RecipientModel?> getRecipientById(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('recipients')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return RecipientModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch recipient', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching recipient', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch recipient', error: e);
    }
  }

  Future<RecipientModel> createRecipient(RecipientModel recipient) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final recipientData = recipient.toInsertJson();
      recipientData['user_id'] = userId;

      final response = await _supabase
          .from('recipients')
          .insert(recipientData)
          .select()
          .single();

      final created = RecipientModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created recipient: ${created.name}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create recipient', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating recipient', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create recipient', error: e);
    }
  }

  Future<RecipientModel> updateRecipient(RecipientModel recipient) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('recipients')
          .update(recipient.toInsertJson())
          .eq('id', recipient.id)
          .eq('user_id', userId)
          .select()
          .single();

      final updated = RecipientModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated recipient: ${updated.name}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update recipient', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating recipient', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update recipient', error: e);
    }
  }

  Future<void> deleteRecipient(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      await _supabase
          .from('recipients')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      AppLogger.info('Deleted recipient: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete recipient', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting recipient', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete recipient', error: e);
    }
  }

  Future<void> archiveRecipient(String id, bool archive) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      await _supabase
          .from('recipients')
          .update({'archived': archive})
          .eq('id', id)
          .eq('user_id', userId);

      AppLogger.info('${archive ? 'Archived' : 'Unarchived'} recipient: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to archive recipient', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error archiving recipient', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to archive recipient', error: e);
    }
  }

  Stream<List<RecipientModel>> watchRecipients({bool includeArchived = false}) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.error(const AuthenticationException(message: 'User not authenticated'));
    }

    return _supabase
        .from('recipients')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('priority', ascending: false)
        .order('name', ascending: true)
        .map((data) {
          var recipients = data.map((json) => RecipientModel.fromJson(json)).toList();
          if (!includeArchived) {
            recipients = recipients.where((r) => !r.archived).toList();
          }
          return recipients;
        });
  }
}
