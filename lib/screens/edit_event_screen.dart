import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:letshang/screens/add_people_event_screen.dart';
import 'package:letshang/screens/events/add_invitee_dialog.dart';
import 'package:letshang/services/message_service.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:letshang/widgets/picture_chooser.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:letshang/widgets/lh_text_form_field.dart';
import 'package:letshang/widgets/member_card.dart';

class EditEventScreen extends StatelessWidget {
  final HangEvent? curEvent;
  const EditEventScreen({Key? key, this.curEvent}) : super(key: key);

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
        body: BlocProvider(
            create: (context) => EditHangEventsBloc(
                hangEventRepository: HangEventRepository(),
                creatingUser: HangUserPreview.fromUser(
                  (context.read<AppBloc>().state).authenticatedUser!,
                ),
                existingHangEvent: curEvent),
            child: _EditEventScreenView(
              curEvent: curEvent,
            )));
  }
}

class _EditEventScreenView extends StatefulWidget {
  final HangEvent? curEvent;
  const _EditEventScreenView({Key? key, this.curEvent}) : super(key: key);
  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<_EditEventScreenView> {
  final _formKey = GlobalKey<FormState>();
  // late DateTime selectedStartDate;
  // late DateTime selectedEndDate;
  // late TimeOfDay selectedStartTime;
  // late TimeOfDay selectedEndTime;
  bool isAllDayEvent = false;

  // void initState() {
  //   if (widget.curEvent != null) {
  //     selectedStartDate = widget.curEvent!.eventStartDate;
  //     selectedStartTime =
  //         TimeOfDay.fromDateTime(widget.curEvent!.eventStartDate);

  //     selectedEndDate = widget.curEvent!.eventEndDate;
  //     selectedEndTime = TimeOfDay.fromDateTime(widget.curEvent!.eventEndDate);
  //   } else {
  //     // if we are creating a new event, then make sure the dates round up to the next hour
  //     selectedStartDate = _roundDateToNextHour(DateTime.now());
  //     selectedStartTime = TimeOfDay.fromDateTime(selectedStartDate);

  //     selectedEndDate = _roundDateToNextHour(DateTime.now());
  //     selectedEndTime = TimeOfDay.fromDateTime(selectedEndDate);
  //   }
  //   super.initState();
  // }

  Future<void> _selectStartDate(
      BuildContext context, DateTime? curStartDate) async {
    DateTime todaysDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: curStartDate ?? todaysDate,
        firstDate: todaysDate,
        lastDate: DateTime(2101));
    if (picked != null) {
      // once a different date is picked, reset the start time.
      context.read<EditHangEventsBloc>().add(EventStartDateChanged(
            eventStartDate: picked,
          ));
      // setState(() {
      //   selectedStartDate = picked;
      //   selectedStartTime = constants.startOfDay;
      //   context.read<EditHangEventsBloc>().add(EventStartDateChanged(
      //         eventStartDate: selectedStartDate,
      //       ));
      //   if (selectedStartDate.isAfter(selectedEndDate)) {
      //     // if the start date is after the end date, then we need to adjust the end date to be the start date
      //     selectedEndDate = selectedStartDate;
      //     selectedEndTime = constants.startOfDay;
      //     context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
      //         eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));
      //   }
      // });
    }
  }

  // Future<void> _selectEndDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: selectedEndDate,
  //       firstDate: selectedStartDate,
  //       lastDate: DateTime(2101));
  //   if (picked != null && picked != selectedEndDate) {
  //     // once a different date is picked, reset the start time.
  //     setState(() {
  //       selectedEndDate = picked;
  //       selectedEndTime = constants.startOfDay;
  //       context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
  //           eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));
  //     });
  //   }
  // }

  Future<void> _selectStartTime(
      BuildContext context, TimeOfDay? curStartTime) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: curStartTime ?? constants.startOfDay,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != curStartTime) {
      context
          .read<EditHangEventsBloc>()
          .add(EventStartTimeChanged(eventStartTime: timeOfDay));
      // setState(() {
      //   selectedStartTime = timeOfDay;
      //   context
      //       .read<EditHangEventsBloc>()
      //       .add(EventStartTimeChanged(eventStartTime: selectedStartTime));

      //   DateTime curStartDateTime = DateTimeUtils.getCurrentDateTime(
      //       date: selectedStartDate, timeOfDay: selectedStartTime);
      //   DateTime curEndDateTime = DateTimeUtils.getCurrentDateTime(
      //       date: selectedEndDate, timeOfDay: selectedEndTime);
      //   if (curStartDateTime.compareTo(curEndDateTime) >= 0) {
      //     // if the start date is after the end date, then we need to adjust the end date to be the start date
      //     selectedEndDate = selectedStartDate;
      //     selectedEndTime = selectedStartTime;
      //     context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
      //         eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));
      //   }
      // });
    }
  }

  // Future<void> _selectEndTime(BuildContext context) async {
  //   final TimeOfDay? timeOfDay = await showTimePicker(
  //     context: context,
  //     initialTime: selectedEndTime,
  //     initialEntryMode: TimePickerEntryMode.dial,
  //   );
  //   if (timeOfDay != null && timeOfDay != selectedEndTime) {
  //     setState(() {
  //       selectedEndTime = timeOfDay;
  //       context.read<EditHangEventsBloc>().add(EventEndDateTimeChanged(
  //           eventEndDate: selectedEndDate, eventEndTime: selectedEndTime));

  //       DateTime curStartDateTime = DateTimeUtils.getCurrentDateTime(
  //           date: selectedStartDate, timeOfDay: selectedStartTime);
  //       DateTime curEndDateTime = DateTimeUtils.getCurrentDateTime(
  //           date: selectedEndDate, timeOfDay: selectedEndTime);
  //       if (curStartDateTime.isAfter(curEndDateTime)) {
  //         selectedEndDate = selectedStartDate;
  //         selectedEndTime = selectedStartTime;
  //         // context.read<EditHangEventsBloc>().add(EventStartDateTimeChanged(
  //         //     eventStartDate: selectedStartDate,
  //         //     eventStartTime: selectedStartTime));
  //         MessageService.showErrorMessage(
  //             content: 'End date cannot be before the start date',
  //             context: context);
  //       }
  //     });
  //   }
  // }

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
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
                    builder: (context, state) {
                      return LHTextFormField(
                        labelText: 'Event Name',
                        initialValue: state.eventName,
                        backgroundColor: Colors.white,
                        onChanged: (value) {
                          context
                              .read<EditHangEventsBloc>()
                              .add(EventNameChanged(eventName: value));
                        },
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: const LHTextFormField(
                        labelText: 'Location', backgroundColor: Colors.white),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(children: [
                      Flexible(
                          flex: 1,
                          child: BlocBuilder<EditHangEventsBloc,
                              EditHangEventsState>(
                            builder: (context, state) {
                              return InkWell(
                                  onTap: () {
                                    _selectStartDate(
                                        context, state.eventStartDateTime);
                                  },
                                  child: LHTextFormField(
                                    labelText: state.eventStartDateTime != null
                                        ? DateFormat('MM/dd/yyyy')
                                            .format(state.eventStartDateTime!)
                                        : 'Date',
                                    backgroundColor: Colors.white,
                                    enabled: false,
                                    readOnly: true,
                                  ));
                            },
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                          flex: 1,
                          child: BlocBuilder<EditHangEventsBloc,
                              EditHangEventsState>(
                            builder: (context, state) {
                              return InkWell(onTap: () {
                                _selectStartTime(context, state.eventStartTime);
                              }, child: BlocBuilder<EditHangEventsBloc,
                                      EditHangEventsState>(
                                  builder: (context, state) {
                                return LHTextFormField(
                                  labelText: state.eventStartTime != null
                                      ? _changeTimeToString(
                                          state.eventStartTime!)
                                      : 'Time',
                                  backgroundColor: Colors.white,
                                  enabled: false,
                                  readOnly: true,
                                );
                              }));
                            },
                          ))
                    ]),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Limit Guest Count',
                                    style:
                                        Theme.of(context).textTheme.bodyText1!),
                                Switch(
                                    value: state.limitGuestCount,
                                    onChanged: (bool value) {
                                      context.read<EditHangEventsBloc>().add(
                                          LimitGuestCountToggled(
                                              limitGuestCountValue: value));
                                      // This is called when the user toggles the switch.
                                    })
                              ],
                            ),
                            if (state.limitGuestCount) ...[
                              LHTextFormField(
                                labelText: 'Max Number of Guests',
                                backgroundColor: Colors.white,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => context
                                    .read<EditHangEventsBloc>()
                                    .add(MaxGuestCountChanged(
                                        maxGuestCount: int.parse(value))),
                              )
                            ]
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text('Event Type',
                        style: Theme.of(context).textTheme.bodyText1!),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: ToggleSwitch(
                        minWidth: 200.0,
                        cornerRadius: 20.0,
                        activeBgColors: const [
                          [Color(0xFF0286BF)],
                          [Color(0xFF0286BF)]
                        ],
                        inactiveBgColor: Colors.white,
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: const ['Public', 'Private'],
                        icons: const [Icons.public, Icons.lock],
                        radiusStyle: true,
                        onToggle: (index) {
                          context.read<EditHangEventsBloc>().add(
                              EventTypeToggled(
                                  eventType: index == 1
                                      ? HangEventType.public
                                      : HangEventType.private));
                        },
                      )),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(5)),
                    child: BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            PictureChooser(
                              chooserImage: Image.asset(
                                  'assets/images/choose_event_pic.png'),
                              onImageChoosen: (croppedFilePath) {
                                context.read<EditHangEventsBloc>().add(
                                      EventPictureChanged(
                                          eventPicturePath: croppedFilePath),
                                    );
                              },
                              onImageError: (error) {
                                context.read<EditHangEventsBloc>().add(
                                    EventPictureChangedError(
                                        eventPictureError: error));
                              },
                              renderImageContainer: (imageFile) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: FileImage(imageFile),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (state.photoUrl?.isEmpty ?? false) ...[
                              Text(
                                'Add Cover Photo',
                                style: Theme.of(context).textTheme.bodyText1!,
                              )
                            ]
                          ],
                        );
                      },
                    ),
                  ),
                  _submitButton(),
                ],
              ),
            )));
  }

  // List<Widget> _startDateTimeFields() {
  //   return [
  //     Text(DateFormat('MM/dd/yyyy').format(selectedStartDate)),
  //     BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
  //       builder: (context, state) {
  //         return IconButton(
  //           icon: const Icon(Icons.calendar_today_rounded),
  //           highlightColor: Colors.pink,
  //           onPressed: () => _selectStartDate(context),
  //         );
  //       },
  //     ),
  //     Text(_changeTimeToString(selectedStartTime)),
  //     BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
  //       builder: (context, state) {
  //         return IconButton(
  //           icon: const Icon(Icons.access_time),
  //           highlightColor: Colors.pink,
  //           onPressed: () => _selectStartTime(context),
  //         );
  //       },
  //     ),
  //   ];
  // }

  // List<Widget> _endDateTimeFields() {
  //   return [
  //     Text(DateFormat('MM/dd/yyyy').format(selectedEndDate)),
  //     BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
  //       builder: (context, state) {
  //         return IconButton(
  //           icon: const Icon(Icons.calendar_today_rounded),
  //           highlightColor: Colors.pink,
  //           onPressed: () => _selectEndDate(context),
  //         );
  //       },
  //     ),
  //     Text(_changeTimeToString(selectedEndTime)),
  //     BlocBuilder<EditHangEventsBloc, EditHangEventsState>(
  //       builder: (context, state) {
  //         return IconButton(
  //           icon: const Icon(Icons.access_time),
  //           highlightColor: Colors.pink,
  //           onPressed: () => _selectEndTime(context),
  //         );
  //       },
  //     ),
  //   ];
  // }

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
          return const Text('No members');
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
      listener: (context, state) async {
        if (state is EventMainDetailsSavedSuccessfully) {
          HangEvent? returnedEvent = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AddPeopleEventScreen(curEvent: state.savedEvent),
            ),
          );
          if (!context.mounted) return;

          if (returnedEvent != null) {
            context
                .read<EditHangEventsBloc>()
                .add(PopulateEventData(eventData: returnedEvent));
          }
        }
        if (state is EventMainDetailsSavedError) {
          MessageService.showErrorMessage(
              content: "Unable to save event details", context: context);
        }
        if (state is EventSavedSuccessfully) {
          MessageService.showSuccessMessage(
              content: "Event saved successfully", context: context);

          // after the event is saved go back to home screen
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: 30),
          width: double.infinity,
          child: state is EventMainDetailsSavedLoading
              ? const Center(child: CircularProgressIndicator())
              : LHButton(
                  buttonText: 'Continue',
                  onPressed: () {
                    context
                        .read<EditHangEventsBloc>()
                        .add(EventMainDetailsSavedInitiated());
                  },
                  isDisabled: context
                      .read<EditHangEventsBloc>()
                      .state
                      .eventName
                      .isEmpty),
        );
      },
    );
  }
}
