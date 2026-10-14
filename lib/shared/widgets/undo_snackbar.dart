import 'package:flutter/material.dart';

/// One line and an Undo action, five seconds. [onUndo] restores the
/// previous values exactly.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required Future<void> Function() onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      // With accessible navigation on, Flutter keeps a snackbar that has an
      // action until it is dismissed; the close icon is that way out.
      showCloseIcon: true,
      action: SnackBarAction(label: 'Undo', onPressed: () => onUndo()),
    ),
  );
}
