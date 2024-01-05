import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DialogService {
  static void showConfirmationDialog(
      BuildContext context, String confirmationMessage, Function onConfirm,
      [String dialogTitle = "Confirm Action"]) {
    final alert = AlertDialog(
      title: Text(dialogTitle),
      content: Text(confirmationMessage),
      actions: [
        TextButton(
            onPressed: () {
              onConfirm();
              context.pop();
            },
            child: const Text("Confirm")),
        TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text("Cancel"))
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
