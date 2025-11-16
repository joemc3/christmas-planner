import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/user_profile.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<User> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw const AuthenticationException(
          message: 'Sign up failed - no user returned',
        );
      }

      AppLogger.info('User signed up: ${response.user!.email}');
      return response.user!;
    } on AuthException catch (e) {
      AppLogger.error('Sign up failed', error: e);
      throw AuthenticationException(
        message: e.message,
        statusCode: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign up', error: e, stackTrace: stackTrace);
      throw AuthenticationException(
        message: 'Sign up failed',
        error: e,
      );
    }
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthenticationException(
          message: 'Sign in failed - no user returned',
        );
      }

      AppLogger.info('User signed in: ${response.user!.email}');
      return response.user!;
    } on AuthException catch (e) {
      AppLogger.error('Sign in failed', error: e);
      throw AuthenticationException(
        message: e.message,
        statusCode: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign in', error: e, stackTrace: stackTrace);
      throw AuthenticationException(
        message: 'Sign in failed',
        error: e,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      AppLogger.info('User signed out');
    } on AuthException catch (e) {
      AppLogger.error('Sign out failed', error: e);
      throw AuthenticationException(
        message: e.message,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign out', error: e, stackTrace: stackTrace);
      throw AuthenticationException(
        message: 'Sign out failed',
        error: e,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      AppLogger.info('Password reset email sent to: $email');
    } on AuthException catch (e) {
      AppLogger.error('Password reset failed', error: e);
      throw AuthenticationException(
        message: e.message,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during password reset', error: e, stackTrace: stackTrace);
      throw AuthenticationException(
        message: 'Password reset failed',
        error: e,
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
      AppLogger.info('Password updated successfully');
    } on AuthException catch (e) {
      AppLogger.error('Password update failed', error: e);
      throw AuthenticationException(
        message: e.message,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during password update', error: e, stackTrace: stackTrace);
      throw AuthenticationException(
        message: 'Password update failed',
        error: e,
      );
    }
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Fetched user profile for: ${profile.email}');
      return profile;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch user profile', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching user profile', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch user profile', error: e);
    }
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final response = await _supabase
          .from('user_profiles')
          .update({
            'full_name': profile.fullName,
            'avatar_url': profile.avatarUrl,
            'timezone': profile.timezone,
            'currency': profile.currency,
            'default_shipping_days': profile.defaultShippingDays,
            'notification_preferences': profile.notificationPreferences,
          })
          .eq('id', userId)
          .select()
          .single();

      final updated = UserProfile.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated user profile for: ${updated.email}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update user profile', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating user profile', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update user profile', error: e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      // Delete user profile (cascade will handle related data)
      await _supabase
          .from('user_profiles')
          .delete()
          .eq('id', userId);

      await signOut();
      AppLogger.info('Account deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete account', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete account', error: e);
    }
  }
}
