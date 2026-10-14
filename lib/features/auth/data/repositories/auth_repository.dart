import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/guard.dart';
import '../../../../shared/models/user_profile.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) => guard('create account', () async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  });

  Future<void> signIn({required String email, required String password}) =>
      guard('sign in', () async {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      });

  Future<void> signOut() => guard('sign out', () => _supabase.auth.signOut());

  /// Sends the recovery email. The link opens the app at /reset.
  Future<void> requestPasswordReset(
    String email, {
    required String redirectTo,
  }) => guard('send the reset link', () async {
    await _supabase.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  });

  Future<void> updatePassword(String newPassword) =>
      guard('save the new password', () async {
        await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      });

  Future<UserProfile> getUserProfile() => guard('load your settings', () async {
    final userId = requireUserId(_supabase);
    final row = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(row);
  });

  Future<UserProfile> updateUserProfile(UserProfile profile) =>
      guard('save your settings', () async {
        final userId = requireUserId(_supabase);
        final row = await _supabase
            .from('user_profiles')
            .update(profile.toUpdateJson())
            .eq('id', userId)
            .select()
            .single();
        return UserProfile.fromJson(row);
      });

  /// Deletes the profile row; the database cascades to every plan, person,
  /// gift and meal. The auth user is removed by the same cascade from
  /// auth.users when the account is deleted server-side; locally we sign out.
  Future<void> deleteAccount() => guard('delete your account', () async {
    final userId = requireUserId(_supabase);
    await _supabase.from('user_profiles').delete().eq('id', userId);
    await _supabase.auth.signOut();
  });
}
