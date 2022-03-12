import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/screens/home_screen.dart';

class EditEventScreen extends StatefulWidget {
  final HangEvent? curEvent;
  const EditEventScreen({Key? key, this.curEvent}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 0, minute: 0);
  bool isAllDayEvent = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime todaysDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: todaysDate,
        firstDate: todaysDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedStartTime) {
      setState(() {
        selectedStartTime = timeOfDay;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedStartTime) {
      setState(() {
        selectedEndTime = timeOfDay;
      });
    }
  }

  String _changeTimeToString(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) =>
          EditHangEventsBloc(hangEventRepository: HangEventRepository()),
      child: SafeArea(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('When'),
            Row(children: [
              Checkbox(
                value: isAllDayEvent,
                onChanged: (newValue) {
                  setState(() {
                    isAllDayEvent = newValue as bool;
                  });
                },
              ),
              const Text('All day event')
            ]), //Checkbox],),
            Row(
              children: [
                Text(DateFormat('MM/dd/yyyy').format(selectedDate)),
                IconButton(
                  icon: const Icon(Icons.calendar_today_rounded),
                  highlightColor: Colors.pink,
                  onPressed: () => _selectDate(context),
                ),
                if (!isAllDayEvent) ...[
                  Text(_changeTimeToString(selectedStartTime)),
                  IconButton(
                    icon: const Icon(Icons.timer),
                    highlightColor: Colors.pink,
                    onPressed: () => _selectStartTime(context),
                  ),
                  const Text('to'),
                  Text(_changeTimeToString(selectedEndTime)),
                  IconButton(
                    icon: const Icon(Icons.timer),
                    highlightColor: Colors.pink,
                    onPressed: () => _selectEndTime(context),
                  ),
                ],
              ],
            ),
            ..._nameFields(),
            ..._detailsFields(),
            const Text('Location'),
            ..._submitButton(),
          ],
        ),
      )),
    ));
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

  List<Widget> _submitButton() {
    return [
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
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
                          id: widget.curEvent?.id ?? "test",
                          eventName: state.eventName,
                          eventDescription: state.eventDescription,
                          eventDate: state.eventDate)));

                  // after the event is saved go back to home screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                } else {
                  // not validated
                }
              },
              child: const Text('Submit'),
            ),
          );
        },
      )
    ];
  }
}
