import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TypeOfEventScreen extends StatelessWidget {
  const TypeOfEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFECEEF4),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF9BADBD),
            ),
            onPressed: () {
              context.pop();
            },
          ),
          title: const Text('Create Event'),
          titleTextStyle: Theme.of(context).textTheme.headline4,
        ),
        body: _TypeOfEventView());
  }
}

class _TypeOfEventView extends StatelessWidget {
  _TypeOfEventView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Let's create an event!"),
                  Text(
                      "To start of we need to determine what type of event you want to create"),
                  Text("I already know the date and time for the event"),
                  Text(
                      "I will figure out the date and time for the event later"),
                ],
              ),
            )));
  }
}
