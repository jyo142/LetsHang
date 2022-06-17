import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/assets/Constants.dart' as constants;
import 'package:letshang/services/message_service.dart';
import 'package:letshang/utils/date_time_utils.dart';

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
          context
              .read<EditHangEventsBloc>()
              .add(EventEndDateTimeChanged(selectedEndDate, selectedEndTime));
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

        DateTime curStartDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedStartDate, timeOfDay: selectedStartTime);
        DateTime curEndDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedEndDate, timeOfDay: selectedEndTime);
        if (curStartDateTime.compareTo(curEndDateTime) >= 0) {
          // if the start date is after the end date, then we need to adjust the end date to be the start date
          selectedEndDate = selectedStartDate;
          selectedEndTime = selectedStartTime;
          context
              .read<EditHangEventsBloc>()
              .add(EventEndDateTimeChanged(selectedEndDate, selectedEndTime));
        }
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

        DateTime curStartDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedStartDate, timeOfDay: selectedStartTime);
        DateTime curEndDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedEndDate, timeOfDay: selectedEndTime);
        if (curStartDateTime.isAfter(curEndDateTime)) {
          selectedEndDate = selectedStartDate;
          selectedEndTime = selectedStartTime;
          context.read<EditHangEventsBloc>().add(
              EventStartDateTimeChanged(selectedStartDate, selectedStartTime));
          MessageService.showErrorMessage(
              content: 'End date cannot be before the start date',
              context: context);
        }
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
      create: (context) => EditHangEventsBloc(
          hangEventRepository: HangEventRepository(),
          existingHangEvent: widget.curEvent),
      child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date and Time *'),
                    Row(
                      children: _startDateTimeFields(),
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
                    Row(
                      children: [
                        _submitButton(),
                        ElevatedButton(
                          onPressed: () {
                            // after the event is saved go back to home screen
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: const Text('Cancel'),
                        )
                      ],
                    )
                  ],
                ),
              ))),
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
                context.read<EditHangEventsBloc>().add(EventSaved());

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
