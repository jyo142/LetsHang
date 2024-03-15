import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:intl/intl.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/utils/date_time_utils.dart';
import 'package:letshang/widgets/events/create_event/create_event_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateEventReviewStep implements CreateEventStep {
  @override
  String get stepTitle => "Review event details";

  @override
  String get stepId => "review";

  @override
  Widget getStepWidget(CreateEventState createEventState) {
    return CreateEventReviewStepWidget(
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

class CreateEventReviewStepWidget extends StatelessWidget {
  final CreateEventState createEventState;
  final String stepId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  CreateEventReviewStepWidget(
      {Key? key, required this.createEventState, required this.stepId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Event Name",
                    style: Theme.of(context).textTheme.headline6),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(createEventState.eventName,
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Event Description",
                    style: Theme.of(context).textTheme.headline6!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(createEventState.eventDescription,
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Row(
              children: [
                InkWell(
                  // on Tap function used and call back function os defined here
                  onTap: () {
                    context.read<CreateEventBloc>().add(const MoveExactStage(
                        eventStage: HangEventStage.nameDescription));
                  },
                  child: Text(
                    'Edit event name and duration',
                    style: Theme.of(context).textTheme.linkText,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Event Start Date",
                    style: Theme.of(context).textTheme.headline6!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    createEventState.timeAndDateKnown == CreateEventYesNo.yes
                        ? DateFormat('MM/dd/yyyy')
                            .format(createEventState.eventStartDateTime!)
                        : "Unknown",
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Event Start Time",
                    style: Theme.of(context).textTheme.headline6!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    createEventState.timeAndDateKnown == CreateEventYesNo.yes
                        ? DateTimeUtils.changeTimeToString(
                            createEventState.eventStartTime!)
                        : "Unknown",
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Event Duration",
                    style: Theme.of(context).textTheme.headline6!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    createEventState.timeAndDateKnown == CreateEventYesNo.yes
                        ? "${createEventState.durationHours} hour(s)"
                        : "Unknown",
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Row(
              children: [
                InkWell(
                  // on Tap function used and call back function os defined here
                  onTap: () {
                    context.read<CreateEventBloc>().add(const MoveExactStage(
                        eventStage: HangEventStage.dateTime));
                  },
                  child: Text(
                    'Edit event start date, time, and duration',
                    style: Theme.of(context).textTheme.linkText,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Is Recurring Event",
                    style: Theme.of(context).textTheme.headline6!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    createEventState.isRecurringEvent == CreateEventYesNo.yes
                        ? "Yes"
                        : "No",
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            if (createEventState.isRecurringEvent == CreateEventYesNo.yes) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      "Recurring every ${createEventState.recurringFrequency} ${CreateEventUtils.getRecurringIntervalName(createEventState.recurringType!)}",
                      style: Theme.of(context).textTheme.bodyText1!),
                ],
              ),
            ],
            Row(
              children: [
                InkWell(
                  // on Tap function used and call back function os defined here
                  onTap: () {
                    context.read<CreateEventBloc>().add(const MoveExactStage(
                        eventStage: HangEventStage.recurringEvent));
                  },
                  child: Text(
                    'Edit event recurring settings',
                    style: Theme.of(context).textTheme.linkText,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Location", style: Theme.of(context).textTheme.headline6!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    createEventState.eventLocationKnown == CreateEventYesNo.yes
                        ? createEventState.eventLocation!
                        : "Unknown",
                    style: Theme.of(context).textTheme.bodyText1!),
              ],
            ),
            Row(
              children: [
                InkWell(
                  // on Tap function used and call back function os defined here
                  onTap: () {
                    context.read<CreateEventBloc>().add(const MoveExactStage(
                        eventStage: HangEventStage.location));
                  },
                  child: Text(
                    'Edit Event Location',
                    style: Theme.of(context).textTheme.linkText,
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
