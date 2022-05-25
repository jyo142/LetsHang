import 'package:flutter/material.dart';

class AddMemberDialog extends StatefulWidget {
  @override
  AddMemberDialogState createState() => new AddMemberDialogState();
}

class AddMemberDialogState extends State<AddMemberDialog> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Add new member'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: Column(
          children: [
            Text(
              'Username',
              style: Theme.of(context).textTheme.headline5,
            ),
            TextFormField(),
            Text(
              'Results',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      )),
    );
  }
}
