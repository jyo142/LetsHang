import 'package:flutter/material.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/lh_text_form_field.dart';

class EventLocationStep implements CreateEventStep {
  @override
  String get stepTitle => "Where is the event happening?";

  @override
  String get stepId => "location";

  @override
  Widget getStepWidget(CreateEventState createEventState) {
    return EventLocationStepWidget(
      createEventState: createEventState,
      stepId: stepId,
    );
  }

  @override
  Map<String, String> validate(CreateEventState createEventState) {
    Map<String, String> stepMap = <String, String>{};
    if (createEventState.eventLocationKnown == null) {
      stepMap.putIfAbsent("locationKnown", () => "Please enter a value");
    } else {
      if (createEventState.timeAndDateKnown == CreateEventYesNo.yes) {
        if (createEventState.eventStartDateTime == null) {
          stepMap.putIfAbsent(
              "eventLocation", () => "Please enter a start date");
        }
      }
    }
    return stepMap;
  }
}

class EventLocationStepWidget extends StatelessWidget {
  final CreateEventState createEventState;
  final String stepId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EventLocationStepWidget(
      {Key? key, required this.createEventState, required this.stepId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, String>? curStepValidationMap =
        createEventState.formStepValidationMap.containsKey(stepId)
            ? createEventState.formStepValidationMap[stepId]
            : {};

    return Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Do you know the location for the event?",
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Yes'),
                  leading: Radio<CreateEventYesNo>(
                    value: CreateEventYesNo.yes,
                    groupValue: createEventState.eventLocationKnown,
                    onChanged: (CreateEventYesNo? value) {
                      context.read<CreateEventBloc>().add(
                          EventLocationKnownChanged(
                              eventLocationKnown: value!));
                    },
                  ),
                ),
                ListTile(
                  title: const Text('No'),
                  leading: Radio<CreateEventYesNo>(
                    value: CreateEventYesNo.no,
                    groupValue: createEventState.eventLocationKnown,
                    onChanged: (CreateEventYesNo? value) {
                      context.read<CreateEventBloc>().add(
                          EventLocationKnownChanged(
                              eventLocationKnown: value!));
                    },
                  ),
                ),
              ],
            ),
            if (curStepValidationMap?.containsKey("locationKnown") ??
                false) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    curStepValidationMap!["locationKnown"]!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .merge(const TextStyle(color: Color(0xFFFF4D53))),
                  )
                ],
              )
            ],
            if (createEventState.eventLocationKnown ==
                CreateEventYesNo.yes) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Please enter the location for the event",
                      style: Theme.of(context).textTheme.bodyText1!),
                ],
              ),
              LHTextFormField(
                labelText: 'Event Location',
                initialValue: createEventState.eventLocation ?? "",
                backgroundColor: const Color(0xFFECEEF4),
                maxLines: 1,
                onChanged: (value) {
                  context
                      .read<CreateEventBloc>()
                      .add(EventLocationChanged(eventLocation: value));
                },
                errorText:
                    curStepValidationMap?.containsKey("eventLocation") ?? false
                        ? curStepValidationMap!["eventLocation"]
                        : null,
              ),
            ]
          ],
        ));
  }
}
