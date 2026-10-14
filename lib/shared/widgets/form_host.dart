import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';

/// Shows a form as a bottom sheet below 840 px and a dialog at or above.
/// The form widget itself is the same in both.
Future<T?> showFormHost<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (WindowSize.of(context).isCompact) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: builder(context),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, minWidth: 480),
        child: builder(context),
      ),
    ),
  );
}

/// Title, fields, then Cancel and one primary action. Shows a spinner
/// while [onSubmit] runs and keeps the form open on failure.
class FormScaffold extends StatefulWidget {
  const FormScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSubmit,
    required this.submitLabel,
    this.leading,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Future<void> Function() onSubmit;
  final String submitLabel;

  /// An action on the left of the buttons row, such as Delete when editing.
  final Widget? leading;

  @override
  State<FormScaffold> createState() => _FormScaffoldState();
}

class _FormScaffoldState extends State<FormScaffold> {
  bool _saving = false;

  Future<void> _submit() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.xl,
          Space.sm,
          Space.xl,
          Space.xl,
        ),
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: Space.lg),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final child in widget.children) ...[
                      child,
                      const SizedBox(height: Space.lg),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Space.sm),
              Row(
                children: [
                  if (widget.leading != null) widget.leading!,
                  const Spacer(),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: Space.sm),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.submitLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label above a field (brief A1: labels never collide with input text).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
  });

  final String label;
  final Widget child;

  /// One line beneath the field.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Merged so the field's accessible name is the label above it.
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          child,
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A money input with the currency symbol as prefix.
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.currency,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String currency;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    autofocus: autofocus,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
    decoration: InputDecoration(
      prefixText: '${currencySymbol(currency)} ',
      hintText: '0.00',
    ),
    validator: validator,
    onChanged: onChanged,
    textInputAction: TextInputAction.next,
  );
}

/// A whole-number input with minus and plus buttons.
class WholeNumberField extends StatelessWidget {
  const WholeNumberField({
    super.key,
    required this.controller,
    this.min = 0,
    this.max = 999,
    this.onChanged,
  });

  final TextEditingController controller;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;

  int get _value => int.tryParse(controller.text) ?? min;

  void _set(int v) {
    final clamped = v.clamp(min, max);
    controller.text = clamped.toString();
    onChanged?.call(clamped);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton.outlined(
        tooltip: 'Fewer',
        onPressed: () => _set(_value - 1),
        icon: const Icon(Icons.remove_rounded),
      ),
      const SizedBox(width: Space.sm),
      Expanded(
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          onChanged: (v) => onChanged?.call(int.tryParse(v) ?? min),
          validator: (v) {
            final n = int.tryParse(v ?? '');
            if (n == null) return 'Enter a whole number';
            if (n < min || n > max) return 'Between $min and $max';
            return null;
          },
        ),
      ),
      const SizedBox(width: Space.sm),
      IconButton.outlined(
        tooltip: 'More',
        onPressed: () => _set(_value + 1),
        icon: const Icon(Icons.add_rounded),
      ),
    ],
  );
}

/// Shows an error from a failed save without dismissing the form.
void showErrorSnackBar(BuildContext context, Object error) {
  final text = error.toString().replaceFirst(RegExp(r'^\w+Exception: '), '');
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
