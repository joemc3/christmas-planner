import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/models/user_profile.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

/// True from the moment the recovery link is opened until the new password
/// is saved; the router sends the user to /reset meanwhile.
final passwordRecoveryProvider = NotifierProvider<_RecoveryFlag, bool>(
  _RecoveryFlag.new,
);

class _RecoveryFlag extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

/// The signed-in user. Supabase emits its initial session during
/// initialize(), before any widget subscribes, so start with the recovered
/// user and then follow sign-in, sign-out and refresh events.
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  Stream<User?> states() async* {
    yield repo.currentUser;
    await for (final event in repo.authStateChanges) {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        ref.read(passwordRecoveryProvider.notifier).set(true);
      }
      yield event.session?.user;
    }
  }

  return states();
});

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateProvider).asData?.value,
);

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).getUserProfile();
});

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController {
  AuthController(this._ref);
  final Ref _ref;
  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) => _repo.signUp(email: email, password: password, fullName: fullName);

  Future<void> signIn({required String email, required String password}) =>
      _repo.signIn(email: email, password: password);

  Future<void> signOut() => _repo.signOut();

  Future<void> requestPasswordReset(
    String email, {
    required String redirectTo,
  }) => _repo.requestPasswordReset(email, redirectTo: redirectTo);

  Future<void> updatePassword(String newPassword) async {
    await _repo.updatePassword(newPassword);
    _ref.read(passwordRecoveryProvider.notifier).set(false);
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final updated = await _repo.updateUserProfile(profile);
    _ref.invalidate(userProfileProvider);
    return updated;
  }

  Future<void> deleteAccount() => _repo.deleteAccount();
}
