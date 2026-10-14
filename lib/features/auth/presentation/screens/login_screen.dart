import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/form_host.dart';
import '../providers/auth_provider.dart';
import 'auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider)
          .signIn(email: _email.text.trim(), password: _password.text);
      // The router redirects on the auth change.
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Christmas Planner',
    lead: 'Gifts and the two Christmas meals, inside the money.',
    children: [
      Form(
        key: _formKey,
        child: AutofillGroup(
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
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: Space.lg),
              LabeledField(
                label: 'Password',
                child: PasswordField(
                  controller: _password,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) =>
                      Validators.validateRequired(v, fieldName: 'Password'),
                  onSubmitted: (_) => _signIn(),
                ),
              ),
              const SizedBox(height: Space.xl),
              FilledButton(
                onPressed: _busy ? null : _signIn,
                child: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: Space.md),
      TextButton(
        onPressed: () => context.go('/forgot'),
        child: const Text('Forgot your password?'),
      ),
      const SizedBox(height: Space.xl),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New here?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: () => context.go('/register'),
            child: const Text('Create an account'),
          ),
        ],
      ),
    ],
  );
}
