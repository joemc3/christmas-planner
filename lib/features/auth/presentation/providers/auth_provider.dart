import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../../../shared/models/user_profile.dart';
import '../../data/repositories/auth_repository.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.map((event) => event.session?.user);
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value;
});

// User Profile Provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    final authRepo = ref.watch(authRepositoryProvider);
    return await authRepo.getUserProfile();
  } catch (e, stackTrace) {
    AppLogger.error('Failed to load user profile', error: e, stackTrace: stackTrace);
    return null;
  }
});

// Auth Controller
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authRepository.signIn(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authRepository.resetPassword(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _authRepository.updatePassword(newPassword);
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    return await _authRepository.updateUserProfile(profile);
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
  }
}
