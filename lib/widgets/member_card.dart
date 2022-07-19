import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final String userName;
  final String name;
  final VoidCallback onDelete;
  final bool canDelete;
  const MemberCard(
      {Key? key,
      required this.userName,
      required this.name,
      required this.onDelete,
      this.canDelete = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      trailing: PopupMenuButton(
          onSelected: (value) => {
                if (value == 0) {startDelete(context)}
              },
          itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Delete"),
                  enabled: canDelete,
                  value: 0,
                ),
              ]),
      title: Text(userName),
      subtitle: Text(name),
    ));
  }

  void startDelete(BuildContext context) {
    final alert = AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure you want to delete?"),
      actions: [
        TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: const Text("Delete")),
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
