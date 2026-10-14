import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/guard.dart';
import '../models/plan_model.dart';

class PlanRepository {
  PlanRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// The caller's plan for [year] with its two meals, created if missing.
  Future<PlanModel> ensurePlan(int year) => guard('ensure plan', () async {
    requireUserId(_supabase);
    final row = await _supabase.rpc('ensure_plan', params: {'p_year': year});
    return PlanModel.fromJson(Map<String, dynamic>.from(row as Map));
  });

  /// Every plan the user has, newest year first. Live.
  Stream<List<PlanModel>> watchPlans() {
    final userId = requireUserId(_supabase);
    return _supabase
        .from('plans')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('year', ascending: false)
        .map((rows) => rows.map(PlanModel.fromJson).toList());
  }

  Future<PlanModel> updateGiftBudget(String planId, double amount) =>
      guard('update gift budget', () async {
        final row = await _supabase
            .from('plans')
            .update({'gift_budget_total': amount})
            .eq('id', planId)
            .select()
            .single();
        return PlanModel.fromJson(row);
      });
}
