import 'package:flutter/material.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/events/hang_event_recurring_settings.dart';
import 'package:letshang/widgets/lh_text_form_field.dart';

class EventRecurringStep implements CreateEventStep {
  @override
  String get stepTitle => "Is this a recurring event?";

  @override
  String get stepId => "recurringEvent";

  @override
  Widget getStepWidget(CreateEventState createEventState) {
    return EventRecurringStepWidget(
      createEventState: createEventState,
      stepId: stepId,
    );
  }

  @override
  Map<String, String> validate(CreateEventState createEventState) {
    Map<String, String> stepMap = <String, String>{};
    if (createEventState.isRecurringEvent == null) {
      stepMap.putIfAbsent("isRecurringEvent", () => "Please enter a value");
    } else {
      if (createEventState.recurringType == null) {
        stepMap.putIfAbsent(
            "recurringType", () => "Please enter a recurring type");
      }
      if (createEventState.recurringFrequency == null) {
        stepMap.putIfAbsent(
            "recurringFrequency", () => "Please enter a recurring frequency");
      } else {
        if (createEventState.recurringFrequency == 0) {
          stepMap.putIfAbsent("recurringFrequency",
              () => "Please enter a valid recurring frequency");
        }
      }
    }
    return stepMap;
  }
}

class EventRecurringStepWidget extends StatelessWidget {
  final CreateEventState createEventState;
  final String stepId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EventRecurringStepWidget(
      {Key? key, required this.createEventState, required this.stepId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, String>? curStepValidationMap =
        createEventState.formStepValidationMap.containsKey(stepId)
            ? createEventState.formStepValidationMap[stepId]
            : {};

    String getRecurringIntervalName(HangEventRecurringType recurringType) {
      switch (recurringType) {
        case HangEventRecurringType.daily:
          return "Days";
        case HangEventRecurringType.monthly:
          return "Months";
        case HangEventRecurringType.weekly:
          return "Weeks";
        case HangEventRecurringType.yearly:
          return "Years";
      }
    }

    return Form(
        key: formKey,
        child: Column(
          children: [
            Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Yes'),
                  leading: Radio<CreateEventYesNo>(
                    value: CreateEventYesNo.yes,
                    groupValue: createEventState.isRecurringEvent,
                    onChanged: (CreateEventYesNo? value) {
                      context.read<CreateEventBloc>().add(
                          IsRecurringEventChanged(
                              stepId: stepId,
                              isRecurringEvent: value!,
                              fieldName: "isRecurringEvent"));
                    },
                  ),
                ),
                ListTile(
                  title: const Text('No'),
                  leading: Radio<CreateEventYesNo>(
                    value: CreateEventYesNo.no,
                    groupValue: createEventState.isRecurringEvent,
                    onChanged: (CreateEventYesNo? value) {
                      context.read<CreateEventBloc>().add(
                          IsRecurringEventChanged(
                              stepId: stepId,
                              isRecurringEvent: value!,
                              fieldName: "isRecurringEvent"));
                    },
                  ),
                ),
              ],
            ),
            if (curStepValidationMap?.containsKey("isRecurringEvent") ??
                false) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    curStepValidationMap!["isRecurringEvent"]!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .merge(const TextStyle(color: Color(0xFFFF4D53))),
                  )
                ],
              )
            ],
            if (createEventState.isRecurringEvent == CreateEventYesNo.yes) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Repeat Type",
                      style: Theme.of(context).textTheme.bodyText1!),
                ],
              ),
              DropdownButtonFormField<HangEventRecurringType>(
                value: createEventState.recurringType,
                validator: (value) {
                  if (value == null) {
                    return "Please choose a user to assign this responsibility to";
                  }
                  return null;
                },
                onChanged: (HangEventRecurringType? recurringType) {
                  if (recurringType != null) {
                    context.read<CreateEventBloc>().add(
                        RecurringTypeChanged(recurringType: recurringType));
                  }
                  FocusScope.of(context).unfocus();
                },
                items: HangEventRecurringType.values.map(
                  (HangEventRecurringType recurringType) {
                    return DropdownMenuItem<HangEventRecurringType>(
                      value: recurringType,
                      child: Text(recurringType.name),
                    );
                  },
                ).toList(),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 10,
              ),
              if (createEventState.recurringType != null) ...[
                Row(
                  children: [
                    Text("Every",
                        style: Theme.of(context).textTheme.bodyText1!),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: LHTextFormField(
                      labelText: "Interval",
                      backgroundColor: const Color(0xFFECEEF4),
                      initialValue: createEventState.recurringFrequency == null
                          ? ""
                          : createEventState.recurringFrequency.toString(),
                      onChanged: (value) {
                        context.read<CreateEventBloc>().add(
                            RecurringFrequencyChanged(
                                recurringFrequency:
                                    value.isEmpty ? 0 : int.parse(value)));
                      },
                      keyboardType: TextInputType.number,
                      errorText: curStepValidationMap
                                  ?.containsKey("recurringFrequency") ??
                              false
                          ? curStepValidationMap!["recurringFrequency"]
                          : null,
                    )),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                        getRecurringIntervalName(
                            createEventState.recurringType!),
                        style: Theme.of(context).textTheme.bodyText1!),
                  ],
                )
              ]
            ]
          ],
        ));
  }
}
