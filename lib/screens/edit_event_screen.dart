import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/assets/Constants.dart' as constants;
import 'package:letshang/screens/events/add_invitee_dialog.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/utils/date_time_utils.dart';
import 'package:letshang/widgets/member_card.dart';

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
        context.read<EditHangEventsBloc>().add(EventStartDateTimeChanged(
            eventStartDate: selectedStartDate,
            eventStartTime: selectedStartTime));
        if (selectedStartDate.isAfter(selectedEndDate)) {
          // if the start date is after the end date, then we need to adjust the end date to be the start date
          selectedEndDate = selectedStartDate;
          selectedEndTime = constants.startOfDay;
          context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
              eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));
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
        context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
            eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));
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
        context.read<EditHangEventsBloc>().add(EventStartDateTimeChanged(
            eventStartDate: selectedStartDate,
            eventStartTime: selectedStartTime));

        DateTime curStartDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedStartDate, timeOfDay: selectedStartTime);
        DateTime curEndDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedEndDate, timeOfDay: selectedEndTime);
        if (curStartDateTime.compareTo(curEndDateTime) >= 0) {
          // if the start date is after the end date, then we need to adjust the end date to be the start date
          selectedEndDate = selectedStartDate;
          selectedEndTime = selectedStartTime;
          context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
              eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));
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
        context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
            eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));

        DateTime curStartDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedStartDate, timeOfDay: selectedStartTime);
        DateTime curEndDateTime = DateTimeUtils.getCurrentDateTime(
            date: selectedEndDate, timeOfDay: selectedEndTime);
        if (curStartDateTime.isAfter(curEndDateTime)) {
          selectedEndDate = selectedStartDate;
          selectedEndTime = selectedStartTime;
          context.read<EditHangEventsBloc>().add(EventStartDateTimeChanged(
              eventStartDate: selectedStartDate,
              eventStartTime: selectedStartTime));
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
          creatingUser: HangUserPreview.fromUser(
            (context.read<AppBloc>().state as AppAuthenticated).user,
          ),
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
                    Text(
                      'Event Owner',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
                      builder: (context, state) {
                        return Text(
                          state.eventOwner.userName,
                          style: Theme.of(context).textTheme.bodyText1,
                        );
                      },
                    ),
                    const SizedBox(height: 10.0),
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
                    const Text('Send Invites To'),
                    _eventInvitees(),
                    _addInviteeButton(),
                    Row(
                      children: [
                        _submitButton(),
                        ElevatedButton(
                          onPressed: () {
                            // after the event is saved go back to home screen
                            // Navigator.of(context, rootNavigator: true).pop(true);
                            Navigator.pop(context, true);
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
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return TextFormField(
              decoration: const InputDecoration(labelText: "Name *"),
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
                  .add(EventNameChanged(eventName: value)));
        },
      )
    ];
  }

  List<Widget> _detailsFields() {
    return [
      BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
        builder: (context, state) {
          return TextFormField(
              decoration: const InputDecoration(labelText: "Details"),
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
                  .add(EventDescriptionChanged(eventDescription: value)));
        },
      )
    ];
  }

  Widget _eventInvitees() {
    return BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
      builder: (context, state) {
        if (state.eventUserInvitees.isEmpty) {
          return Text('No members');
        }
        return Expanded(
          child: ListView.builder(
              itemCount: state.eventUserInvitees.length,
              itemBuilder: (BuildContext context, int index) {
                String key = state.eventUserInvitees.keys.elementAt(index);
                return MemberCard(
                    userName: state.eventUserInvitees[key]!.user.userName,
                    name: state.eventUserInvitees[key]!.user.name!,
                    canDelete: state.eventUserInvitees[key]!.user.userName !=
                        state.eventOwner.userName,
                    onDelete: () {
                      context.read<EditHangEventsBloc>().add(
                          DeleteEventInviteeInitiated(
                              eventInviteeUserName: key));
                    });
              }),
        );
      },
    );
  }

  Widget _addInviteeButton() {
    return BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
      builder: (context, state) {
        return ElevatedButton(
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
            final editHangEventsBloc =
                BlocProvider.of<EditHangEventsBloc>(context);

            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return BlocProvider.value(
                      value: editHangEventsBloc,
                      child: const AddInviteeDialog());
                },
                fullscreenDialog: true));
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Add invitee',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _submitButton() {
    return BlocConsumer<EditHangEventsBloc, EditHangEventsState>(
      listener: (context, state) {
        if (state is EventSavedSuccessfully) {
          MessageService.showSuccessMessage(
              content: "Event saved successfully", context: context);

          // after the event is saved go back to home screen
          Navigator.pop(context, true);
        }
      },
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
                context.read<EditHangEventsBloc>().add(EventSavedInitiated());
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
