import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Opens [child] as a full-height modal sheet above the tab bar.
Future<T?> showFormSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: FrostedHearthColors.parchment,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => child,
  );
}

/// Standard layout for create/edit sheets: title, scrolling fields and a
/// primary button. Handles the keyboard inset and shows a spinner while
/// [onSubmit] runs.
class FormSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Future<void> Function() onSubmit;
  final Widget? leadingAction;

  const FormSheet({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSubmit,
    this.submitLabel = 'Save',
    this.leadingAction,
  });

  @override
  State<FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<FormSheet> {
  bool _saving = false;

  Future<void> _submit() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: FrostedHearthColors.inkDark,
                      ),
                    ),
                  ),
                  if (widget.leadingAction != null) widget.leadingAction!,
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Form(
                key: widget.formKey,
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  children: [
                    for (final child in widget.children) ...[
                      child,
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.submitLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows an error from a failed save without dismissing the sheet.
void showErrorSnackBar(BuildContext context, Object error) {
  final text = error.toString().replaceFirst(RegExp(r'^\w+Exception: '), '');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), backgroundColor: AppTheme.error),
  );
}

/// Parses user-entered money like "1,299.99" or "$40" to a double.
double parseMoney(String? value) {
  if (value == null) return 0;
  final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
  return double.tryParse(cleaned) ?? 0;
}
