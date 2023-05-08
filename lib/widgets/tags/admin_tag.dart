import 'package:flutter/material.dart';

class AdminTag extends StatelessWidget {
  const AdminTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xFFe8e2ef),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: const Text(
        "Admin",
        style: TextStyle(color: const Color(0xFF891f8f)),
      ),
    );
  }
}
