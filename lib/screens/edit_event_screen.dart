import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/screens/home_screen.dart';
import 'package:letshang/assets/Constants.dart' as constants;
import 'package:letshang/services/message_service.dart';

class EditEventScreen extends StatefulWidget {
  final HangEvent? curEvent;
  const EditEventScreen({Key? key, this.curEvent}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;
  late TimeOfDay selectedStartTime;
  late TimeOfDay selectedEndTime;
  bool isAllDayEvent = false;

  void initState() {
    if (widget.curEvent != null) {
      selectedStartDate = widget.curEvent!.eventStartDate;
      selectedStartTime =
          TimeOfDay.fromDateTime(widget.curEvent!.eventStartDate);

      selectedEndDate = widget.curEvent!.eventEndDate;
      selectedEndTime = TimeOfDay.fromDateTime(widget.curEvent!.eventEndDate);
    } else {
      // if we are creating a new event, then make sure the dates round up to the next hour
      selectedStartDate = _roundDateToNextHour(DateTime.now());
      selectedStartTime = TimeOfDay.fromDateTime(selectedStartDate);

      selectedEndDate = _roundDateToNextHour(DateTime.now());
      selectedEndTime = TimeOfDay.fromDateTime(selectedEndDate);
    }
    super.initState();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime todaysDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: todaysDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedStartDate) {
      // once a different date is picked, reset the start time.
      setState(() {
        selectedStartDate = picked;
        selectedStartTime = constants.startOfDay;
        context.read<EditHangEventsBloc>().add(
            EventStartDateTimeChanged(selectedStartDate, selectedStartTime));
        if (selectedStartDate.isAfter(selectedEndDate)) {
          // if the start date is after the end date, then we need to adjust the end date to be the start date
          selectedEndDate = selectedStartDate;
          selectedEndTime = constants.startOfDay;
          context.read<EditHangEventsBloc>().add(
              EventEndDateTimeChanged(selectedStartDate, selectedStartTime));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEndDate,
        firstDate: selectedStartDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedEndDate) {
      // once a different date is picked, reset the start time.
      setState(() {
        selectedEndDate = picked;
        selectedEndTime = constants.startOfDay;
        context
            .read<EditHangEventsBloc>()
            .add(EventEndDateTimeChanged(selectedEndDate, selectedEndTime));
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
        context.read<EditHangEventsBloc>().add(
            EventStartDateTimeChanged(selectedStartDate, selectedStartTime));
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedEndTime) {
      setState(() {
        selectedEndTime = timeOfDay;
        context
            .read<EditHangEventsBloc>()
            .add(EventEndDateTimeChanged(selectedEndDate, selectedEndTime));
      });
    }
  }

  DateTime _roundDateToNextHour(DateTime curDate) {
    DateTime newDate = curDate.add(const Duration(hours: 1));
    newDate = DateTime(newDate.year, newDate.month, newDate.day, newDate.hour);
    return newDate;
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
            const Text('Date and Time *'),
            Row(
              children: _startDateTimeFields(),
              // if (!isAllDayEvent) ...[
              //   Text(_changeTimeToString(selectedStartTime)),
              //   IconButton(
              //     icon: const Icon(Icons.timer),
              //     highlightColor: Colors.pink,
              //     onPressed: () => _selectStartTime(context),
              //   ),
              //   const Text('to'),
              //   Text(_changeTimeToString(selectedEndTime)),
              //   IconButton(
              //     icon: const Icon(Icons.timer),
              //     highlightColor: Colors.pink,
              //     onPressed: () => _selectEndTime(context),
              //   ),
              // ],
            ),
            Row(
              children: const [Text("to")],
            ),
            Row(
              children: _endDateTimeFields(),
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

  List<Widget> _startDateTimeFields() {
    return [
      Text(DateFormat('MM/dd/yyyy').format(selectedStartDate)),
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            highlightColor: Colors.pink,
            onPressed: () => _selectStartDate(context),
          );
        },
      ),
      Text(_changeTimeToString(selectedStartTime)),
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.access_time),
            highlightColor: Colors.pink,
            onPressed: () => _selectStartTime(context),
          );
        },
      ),
    ];
  }

  List<Widget> _endDateTimeFields() {
    return [
      Text(DateFormat('MM/dd/yyyy').format(selectedEndDate)),
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            highlightColor: Colors.pink,
            onPressed: () => _selectEndDate(context),
          );
        },
      ),
      Text(_changeTimeToString(selectedEndTime)),
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.access_time),
            highlightColor: Colors.pink,
            onPressed: () => _selectEndTime(context),
          );
        },
      ),
    ];
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
                          id: widget.curEvent?.id ?? "",
                          eventName: state.eventName,
                          eventDescription: state.eventDescription,
                          eventStartDate: state.eventStartDate,
                          eventEndDate: state.eventEndDate)));

                  MessageService.showSuccessMessage(
                      content: "Event saved successfully", context: context);

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
