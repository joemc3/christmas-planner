import 'package:flutter/material.dart';

/// Asks once: a title as a question, one line naming what goes, Cancel and
/// one danger action. Returns true when confirmed.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String actionLabel,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
