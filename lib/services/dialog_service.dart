import 'package:flutter/material.dart';

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
              Navigator.pop(context);
            },
            child: const Text("Confirm")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
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
