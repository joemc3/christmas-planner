import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_host.dart';
import '../providers/auth_provider.dart';
import 'auth_scaffold.dart';

/// Opened from the recovery email: the recovery session is already active,
/// so saving the new password signs the user in.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _again = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider).updatePassword(_password.text);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(currentUserProvider)?.email;
    final signedIn = email != null;
    return AuthScaffold(
      title: 'Choose a new password',
      lead: signedIn
          ? 'For $email'
          : 'Open the link from your email to continue.',
      showMark: false,
      children: [
        if (!signedIn)
          TextButton(
            onPressed: () => context.go('/forgot'),
            child: const Text('Send the link again'),
          )
        else
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormError(_error),
                LabeledField(
                  label: 'New password',
                  hint: 'At least 8 characters.',
                  child: PasswordField(
                    controller: _password,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: Validators.validatePassword,
                  ),
                ),
                const SizedBox(height: Space.lg),
                LabeledField(
                  label: 'New password again',
                  child: PasswordField(
                    controller: _again,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) =>
                        Validators.validateConfirmPassword(v, _password.text),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(height: Space.xl),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: const Text('Save and sign in'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
