import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_mark.dart';

/// The layout the four account screens share: the mark, a title, one line,
/// then a plain form on paper white, at most 440 wide.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.lead,
    required this.children,
    this.showMark = true,
  });

  final String title;
  final String lead;
  final List<Widget> children;
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showMark) ...[
                    const Center(child: AppMark(size: 64)),
                    const SizedBox(height: Space.xl),
                  ],
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  Text(
                    lead,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Space.xxl),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A password field with a reveal button.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _obscure,
    autofillHints: widget.autofillHints,
    decoration: InputDecoration(
      suffixIcon: IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        icon: Icon(
          _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    ),
    validator: widget.validator,
    onFieldSubmitted: widget.onSubmitted,
  );
}

/// One line of error above the form, when a submit fails.
class FormError extends StatelessWidget {
  const FormError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.lg),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message!,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.error),
        ),
      ),
    );
  }
}

String errorText(Object e) =>
    e.toString().replaceFirst(RegExp(r'^\w+Exception: '), '');
