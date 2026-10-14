import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/guard.dart';
import '../models/gift_model.dart';

class GiftRepository {
  GiftRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Every gift the user can see, across all plans. Live. Callers filter by
  /// recipient; RLS scopes the rows to the user.
  Stream<List<GiftModel>> watchAllGifts() => _supabase
      .from('gifts')
      .stream(primaryKey: ['id'])
      .order('name', ascending: true)
      .map((rows) => rows.map(GiftModel.fromJson).toList());

  Future<GiftModel?> getGiftById(String id) => guard('fetch gift', () async {
    final row = await _supabase
        .from('gifts')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : GiftModel.fromJson(row);
  });

  Future<GiftModel> createGift(GiftModel gift) => guard('create gift', () async {
    final row = await _supabase
        .from('gifts')
        .insert(gift.toInsertJson())
        .select()
        .single();
    return GiftModel.fromJson(row);
  });

  /// Writes every editable field, including the dates, so a status change
  /// prepared with [GiftModel.withStatus] lands in one update.
  Future<GiftModel> updateGift(GiftModel gift) => guard('update gift', () async {
    final row = await _supabase
        .from('gifts')
        .update(gift.toInsertJson())
        .eq('id', gift.id)
        .select()
        .single();
    return GiftModel.fromJson(row);
  });

  Future<void> deleteGift(String id) => guard('delete gift', () async {
    await _supabase.from('gifts').delete().eq('id', id);
  });
}
