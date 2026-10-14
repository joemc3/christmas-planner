import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/guard.dart';
import '../models/recipient_model.dart';

class RecipientRepository {
  RecipientRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// The plan's recipients by name. Live; RLS scopes the rows.
  Stream<List<RecipientModel>> watchRecipients(String planId) => _supabase
      .from('recipients')
      .stream(primaryKey: ['id'])
      .eq('plan_id', planId)
      .order('name', ascending: true)
      .map((rows) => rows.map(RecipientModel.fromJson).toList());

  Future<RecipientModel?> getRecipientById(String id) =>
      guard('fetch recipient', () async {
        final row = await _supabase
            .from('recipients')
            .select()
            .eq('id', id)
            .maybeSingle();
        return row == null ? null : RecipientModel.fromJson(row);
      });

  Future<RecipientModel> createRecipient({
    required String planId,
    required String name,
    required double budgetLimit,
  }) => guard('create recipient', () async {
    final row = await _supabase
        .from('recipients')
        .insert({'plan_id': planId, 'name': name, 'budget_limit': budgetLimit})
        .select()
        .single();
    return RecipientModel.fromJson(row);
  });

  Future<RecipientModel> updateRecipient(RecipientModel recipient) =>
      guard('update recipient', () async {
        final row = await _supabase
            .from('recipients')
            .update({
              'name': recipient.name,
              'budget_limit': recipient.budgetLimit,
            })
            .eq('id', recipient.id)
            .select()
            .single();
        return RecipientModel.fromJson(row);
      });

  /// Deletes the person and, by cascade, their gifts.
  Future<void> deleteRecipient(String id) => guard('delete recipient', () async {
    await _supabase.from('recipients').delete().eq('id', id);
  });
}
