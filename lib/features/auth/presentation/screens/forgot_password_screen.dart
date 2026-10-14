import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_host.dart';
import '../providers/auth_provider.dart';
import 'auth_scaffold.dart';

/// Ask for the email, then "check your email". The link in the email
/// opens /reset.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final origin = Uri.base.origin;
      await ref
          .read(authControllerProvider)
          .requestPasswordReset(
            _email.text.trim(),
            redirectTo: '$origin/#/reset',
          );
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthScaffold(
      title: 'Reset your password',
      lead: "We'll email you a link to choose a new one.",
      showMark: false,
      children: [
        if (_sent) ...[
          Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: Space.lg),
          Text(
            'Check your email for a link to reset your password.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: Space.xs),
          Text(
            'Sent to ${_email.text.trim()}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.xl),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to sign in'),
          ),
        ] else ...[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormError(_error),
                LabeledField(
                  label: 'Email',
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.validateEmail,
                    onFieldSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(height: Space.xl),
                FilledButton(
                  onPressed: _busy ? null : _send,
                  child: const Text('Send link'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to sign in'),
          ),
        ],
      ],
    );
  }
}
