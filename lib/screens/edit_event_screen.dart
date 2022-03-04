import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/events/events_bloc.dart';
import 'package:letshang/blocs/events/events_event.dart';
import 'package:letshang/blocs/events/events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({Key? key}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay selectedEndTime = TimeOfDay(hour: 0, minute: 0);
  bool isAllDayEvent = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime todaysDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: todaysDate,
        firstDate: todaysDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectStartTime(BuildContext context) async {
    TimeOfDay beginningOfDay = TimeOfDay(hour: 0, minute: 0);
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
    TimeOfDay beginningOfDay = TimeOfDay(hour: 0, minute: 0);
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
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) => EventsBloc(),
      child: SafeArea(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('When'),
            Row(children: [
              Checkbox(
                value: isAllDayEvent,
                onChanged: (newValue) {
                  setState(() {
                    isAllDayEvent = newValue as bool;
                  });
                },
              ),
              Text('All day event')
            ]), //Checkbox],),
            Row(
              children: [
                Text(DateFormat('MM/dd/yyyy').format(selectedDate)),
                IconButton(
                  icon: new Icon(Icons.calendar_today_rounded),
                  highlightColor: Colors.pink,
                  onPressed: () => _selectDate(context),
                ),
                if (!isAllDayEvent) ...[
                  Text(_changeTimeToString(selectedStartTime)),
                  IconButton(
                    icon: new Icon(Icons.timer),
                    highlightColor: Colors.pink,
                    onPressed: () => _selectStartTime(context),
                  ),
                  Text('to'),
                  Text(_changeTimeToString(selectedEndTime)),
                  IconButton(
                    icon: new Icon(Icons.timer),
                    highlightColor: Colors.pink,
                    onPressed: () => _selectEndTime(context),
                  ),
                ],
              ],
            ),
            ..._nameFields(),
            ..._detailsFields(),
            Text('Location'),
            ..._submitButton(),
          ],
        ),
      )),
    ));
  }

  List<Widget> _nameFields() {
    return [
      Text('Name *'),
      BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          return TextFormField(
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onChanged: (value) =>
                  context.read<EventsBloc>().add(EventNameChanged(value)));
        },
      )
    ];
  }

  List<Widget> _detailsFields() {
    return [
      Text('Details'),
      BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          return TextFormField(
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onChanged: (value) => context
                  .read<EventsBloc>()
                  .add(EventDescriptionChanged(value)));
        },
      )
    ];
  }

  List<Widget> _submitButton() {
    return [
      BlocBuilder<EventsBloc, EventsState>(
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
                } else {
                  context.read<EventsBloc>().add(EventSaved());
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
