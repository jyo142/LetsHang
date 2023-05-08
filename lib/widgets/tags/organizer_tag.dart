import 'package:flutter/material.dart';

class OrganizerTag extends StatelessWidget {
  const OrganizerTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0xFFDEEFE8),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: const Text(
        "Organizer",
        style: TextStyle(color: const Color(0xFF01a245)),
      ),
    );
  }
}
