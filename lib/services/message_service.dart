import 'package:flutter/material.dart';

class MessageService {
  static void showErrorMessage(
      {required String content, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        content,
        style: const TextStyle(color: Colors.white, letterSpacing: 0.5),
      ),
    ));
  }
}
