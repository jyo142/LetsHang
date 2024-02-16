import 'package:flutter/material.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/lh_text_form_field.dart';
import 'package:intl/intl.dart';
import 'package:letshang/assets/Constants.dart' as constants;

class EventTimeDateStep implements CreateEventStep {
  @override
  String get stepTitle => "Choose when the event is taking place";

  @override
  String get stepId => "dateTime";

  @override
  Widget getStepWidget(CreateEventState createEventState) {
    return EventTimeDateStepWidget(
      createEventState: createEventState,
      stepId: stepId,
    );
  }

  @override
  Map<String, String> validate(CreateEventState createEventState) {
    Map<String, String> stepMap = <String, String>{};
    if (createEventState.timeAndDateKnown == null) {
      stepMap.putIfAbsent("timeAndDateKnown", () => "Please enter a value");
    } else {
      if (createEventState.timeAndDateKnown == CreateEventYesNo.yes) {
        if (createEventState.eventStartDateTime == null) {
          stepMap.putIfAbsent(
              "eventStartDateTime", () => "Please enter a start date");
        }
        if (createEventState.eventStartTime == null) {
          stepMap.putIfAbsent(
              "eventStartTime", () => "Please enter a start date time");
        }
        if (createEventState.durationHours == null ||
            createEventState.durationHours == 0) {
          stepMap.putIfAbsent(
              "durationHours", () => "Please enter a duration for the event");
        } else {
          if (createEventState.durationHours! > 23) {
            stepMap.putIfAbsent(
                "durationHours", () => "Event cannot last longer than one day");
          }
        }
      }
    }
    return stepMap;
  }
}

class EventTimeDateStepWidget extends StatelessWidget {
  final CreateEventState createEventState;
  final String stepId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EventTimeDateStepWidget(
      {Key? key, required this.createEventState, required this.stepId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, String>? curStepValidationMap =
        createEventState.formStepValidationMap.containsKey(stepId)
            ? createEventState.formStepValidationMap[stepId]
            : {};
    Future<void> selectStartDate(
        BuildContext context, DateTime? curStartDate) async {
      DateTime todaysDate = DateTime.now();
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: curStartDate ?? todaysDate,
          firstDate: todaysDate,
          lastDate: DateTime(2101));
      if (picked != null) {
        // once a different date is picked, reset the start time.
        context.read<CreateEventBloc>().add(EventStartDateChanged(
              eventStartDate: picked,
            ));
      }
    }

    Future<void> selectStartTime(
        BuildContext context, TimeOfDay? curStartTime) async {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: curStartTime ?? constants.startOfDay,
        initialEntryMode: TimePickerEntryMode.dial,
      );
      if (timeOfDay != null && timeOfDay != curStartTime) {
        context
            .read<CreateEventBloc>()
            .add(EventStartTimeChanged(eventStartTime: timeOfDay));
      }
    }

    String changeTimeToString(TimeOfDay tod) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      final format = DateFormat.jm(); //"6:00 AM"
      return format.format(dt);
    }

    return Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Do you know the date and time for the event?",
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Yes'),
                  leading: Radio<CreateEventYesNo>(
                    value: CreateEventYesNo.yes,
                    groupValue: createEventState.timeAndDateKnown,
                    onChanged: (CreateEventYesNo? value) {
                      context.read<CreateEventBloc>().add(
                          TimeAndDateKnownChanged(timeAndDateKnown: value!));
                    },
                  ),
                ),
                ListTile(
                  title: const Text('No'),
                  leading: Radio<CreateEventYesNo>(
                    value: CreateEventYesNo.no,
                    groupValue: createEventState.timeAndDateKnown,
                    onChanged: (CreateEventYesNo? value) {
                      context.read<CreateEventBloc>().add(
                          TimeAndDateKnownChanged(timeAndDateKnown: value!));
                    },
                  ),
                ),
              ],
            ),
            if (createEventState.timeAndDateKnown == CreateEventYesNo.yes) ...[
              Text(
                  "Please select a start date, time and duration for the event",
                  style: Theme.of(context).textTheme.bodyText1!),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                        onTap: () {
                          selectStartDate(
                              context, createEventState.eventStartDateTime);
                        },
                        child: LHTextFormField(
                          labelText: createEventState.eventStartDateTime != null
                              ? DateFormat('MM/dd/yyyy')
                                  .format(createEventState.eventStartDateTime!)
                              : 'Date',
                          backgroundColor: const Color(0xFFECEEF4),
                          enabled: false,
                          readOnly: true,
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            selectStartTime(
                                context, createEventState.eventStartTime);
                          },
                          child: LHTextFormField(
                            labelText: createEventState.eventStartTime != null
                                ? changeTimeToString(
                                    createEventState.eventStartTime!)
                                : 'Time',
                            backgroundColor: const Color(0xFFECEEF4),
                            enabled: false,
                            readOnly: true,
                            errorText: curStepValidationMap
                                        ?.containsKey("eventStartTime") ??
                                    false
                                ? curStepValidationMap!["eventStartTime"]
                                : null,
                          ))),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              LHTextFormField(
                labelText: "Duration (Hours)",
                backgroundColor: const Color(0xFFECEEF4),
                initialValue: createEventState.durationHours == null
                    ? ""
                    : createEventState.durationHours.toString(),
                onChanged: (value) {
                  context.read<CreateEventBloc>().add(EventDurationChanged(
                      durationHours: value.isEmpty ? 0 : int.parse(value)));
                },
                keyboardType: TextInputType.number,
                errorText:
                    curStepValidationMap?.containsKey("durationHours") ?? false
                        ? curStepValidationMap!["durationHours"]
                        : null,
              )
            ]
          ],
        ));
  }
}
