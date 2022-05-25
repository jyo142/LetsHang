import 'package:flutter/material.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/screens/groups/add_member_dialog.dart';
import 'package:letshang/services/message_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditGroupsScreen extends StatefulWidget {
  final HangEvent? curEvent;
  const EditGroupsScreen({Key? key, this.curEvent}) : super(key: key);

  @override
  _EditGroupsScreenState createState() => _EditGroupsScreenState();
}

class _EditGroupsScreenState extends State<EditGroupsScreen> {
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [const Text('Group Owner'), const Text('heee')],
                    ),
                    Row(
                      children: [const Text('Group Name'), const Text('heee')],
                    ),
                    Row(
                      children: [
                        Text(
                          'Members',
                          style: Theme.of(context).textTheme.headline5,
                        )
                      ],
                    ),
                    Row(
                      children: [Text('No members')],
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.redAccent,
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) {
                              return AddMemberDialog();
                            },
                            fullscreenDialog: true));
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Add new members',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  List<Widget> _nameFields() {
    return [
      const Text('Name *'),
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return TextFormField(
              initialValue: widget.curEvent?.eventName ?? "",
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onChanged: (value) => context
                  .read<EditHangEventsBloc>()
                  .add(EventNameChanged(value)));
        },
      )
    ];
  }

  List<Widget> _detailsFields() {
    return [
      const Text('Details'),
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return TextFormField(
              initialValue: widget.curEvent?.eventDescription ?? "",
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onChanged: (value) => context
                  .read<EditHangEventsBloc>()
                  .add(EventDescriptionChanged(value)));
        },
      )
    ];
  }

  Widget _submitButton() {
    return BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
                context.read<EditHangEventsBloc>().add(EventSaved(
                    event: HangEvent(
                        id: widget.curEvent?.id ?? "",
                        eventName: state.eventName,
                        eventDescription: state.eventDescription,
                        eventStartDate: state.eventStartDate,
                        eventEndDate: state.eventEndDate)));

                MessageService.showSuccessMessage(
                    content: "Event saved successfully", context: context);

                // after the event is saved go back to home screen
                Navigator.pop(context);
              } else {
                // not validated
              }
            },
            child: const Text('Submit'),
          ),
        );
      },
    );
  }
}
