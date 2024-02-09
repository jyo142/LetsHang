import 'package:flutter/material.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:letshang/widgets/lh_text_form_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventNameDescriptionStep implements CreateEventStep {
  static const MAX_EVENT_NAME_CHARACTERS = 50;
  static const MAX_EVENT_DESCRIPTION_CHARACTERS = 100;

  @override
  String get stepId => "nameDescription";
  @override
  String get stepTitle =>
      "Please give a short name and description for the event";

  @override
  Widget getStepWidget(CreateEventState createEventState) {
    return EventNameDescriptionStepWidget(
      createEventState: createEventState,
      stepId: stepId,
    );
  }

  @override
  Map<String, String> validate(CreateEventState createEventState) {
    Map<String, String> stepMap = <String, String>{};
    if (createEventState.eventName.isEmpty) {
      stepMap.putIfAbsent(
          "eventName", () => "Please enter a name for the event");
    } else {
      if (createEventState.eventName.length > MAX_EVENT_NAME_CHARACTERS) {
        stepMap.putIfAbsent(
            "eventName", () => "Event name must be less than 50 characters");
      }
    }
    if (createEventState.eventDescription.isEmpty) {
      stepMap.putIfAbsent(
          "eventDescription", () => "Please enter a description for the event");
    } else {
      if (createEventState.eventDescription.length >
          MAX_EVENT_DESCRIPTION_CHARACTERS) {
        stepMap.putIfAbsent("eventDescription",
            () => "Event description must be less than 100 characters");
      }
    }
    return stepMap;
  }
}

class EventNameDescriptionStepWidget extends StatefulWidget {
  final CreateEventState createEventState;
  final String stepId;
  const EventNameDescriptionStepWidget(
      {Key? key, required this.createEventState, required this.stepId})
      : super(key: key);

  @override
  _EventNameDescriptionStepWidgetState createState() =>
      _EventNameDescriptionStepWidgetState();
}

class _EventNameDescriptionStepWidgetState
    extends State<EventNameDescriptionStepWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Map<String, String>? curStepValidationMap =
        widget.createEventState.formStepValidationMap.containsKey(widget.stepId)
            ? widget.createEventState.formStepValidationMap[widget.stepId]
            : {};
    return Form(
        key: _formKey,
        child: Column(
          children: [
            LHTextFormField(
              labelText: 'Event Name',
              initialValue: widget.createEventState.eventName,
              backgroundColor: const Color(0xFFECEEF4),
              maxLength: EventNameDescriptionStep.MAX_EVENT_NAME_CHARACTERS,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              errorText: curStepValidationMap?.containsKey("eventName") ?? false
                  ? curStepValidationMap!["eventName"]
                  : null,
              onChanged: (value) {
                context
                    .read<CreateEventBloc>()
                    .add(EventNameChanged(eventName: value));
              },
            ),
            const SizedBox(
              height: 20,
            ),
            LHTextFormField(
              labelText: 'Event Description',
              initialValue: widget.createEventState.eventDescription,
              backgroundColor: const Color(0xFFECEEF4),
              maxLength:
                  EventNameDescriptionStep.MAX_EVENT_DESCRIPTION_CHARACTERS,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onChanged: (value) {
                context
                    .read<CreateEventBloc>()
                    .add(EventDescriptionChanged(eventDescription: value));
              },
              errorText:
                  curStepValidationMap?.containsKey("eventDescription") ?? false
                      ? curStepValidationMap!["eventDescription"]
                      : null,
            ),
          ],
        ));
  }
}
