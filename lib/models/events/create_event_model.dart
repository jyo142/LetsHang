import 'package:flutter/material.dart';
import 'package:letshang/blocs/create_event/create_event_bloc.dart';

abstract class CreateEventStep {
  String get stepId;
  String get stepTitle;
  Widget getStepWidget(CreateEventState createEventState);

  // validation function that maps the name of the form field to the error
  Map<String, String> validate(CreateEventState createEventState);
}

enum TimeAndDateKnown { yes, no }
