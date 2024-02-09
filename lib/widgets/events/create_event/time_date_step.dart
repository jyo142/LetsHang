import 'package:flutter/material.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventTimeDateStep implements CreateEventStep {
  @override
  String get stepTitle => "Choose when the event is taking place";

  @override
  Widget getStepWidget(CreateEventState createEventState) {
    return EventTimeDateStepWidget(
      createEventState: createEventState,
    );
  }

  @override
  String get stepId => "dateTime";

  @override
  Map<String, String> validate(CreateEventState createEventState) {
    // TODO: implement validate
    throw UnimplementedError();
  }
}

class EventTimeDateStepWidget extends StatelessWidget {
  final CreateEventState createEventState;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EventTimeDateStepWidget({Key? key, required this.createEventState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            Text("Do you know the date and time for the event?"),
            Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Yes'),
                  leading: Radio<TimeAndDateKnown>(
                    value: TimeAndDateKnown.yes,
                    groupValue: createEventState.timeAndDateKnown,
                    onChanged: (TimeAndDateKnown? value) {
                      context.read<CreateEventBloc>().add(
                          TimeAndDateKnownChanged(timeAndDateKnown: value!));
                    },
                  ),
                ),
                ListTile(
                  title: const Text('No'),
                  leading: Radio<TimeAndDateKnown>(
                    value: TimeAndDateKnown.no,
                    groupValue: createEventState.timeAndDateKnown,
                    onChanged: (TimeAndDateKnown? value) {
                      context.read<CreateEventBloc>().add(
                          TimeAndDateKnownChanged(timeAndDateKnown: value!));
                    },
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
