part of 'create_event_bloc.dart';

abstract class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object> get props => [];
}

class LoadEventStep extends CreateEventEvent {}

class EventNameChanged extends CreateEventEvent {
  const EventNameChanged({required this.eventName});

  final String eventName;

  @override
  List<Object> get props => [eventName];
}

class EventDescriptionChanged extends CreateEventEvent {
  const EventDescriptionChanged({required this.eventDescription});

  final String eventDescription;

  @override
  List<Object> get props => [eventDescription];
}

class TimeAndDateKnownChanged extends CreateEventEvent {
  const TimeAndDateKnownChanged({required this.timeAndDateKnown});

  final CreateEventYesNo timeAndDateKnown;

  @override
  List<Object> get props => [timeAndDateKnown];
}

class MoveNextStep extends CreateEventEvent {
  const MoveNextStep(
      {required this.stepId, required this.stepValidationFunction});

  final String stepId;
  final Map<String, String> Function(CreateEventState) stepValidationFunction;

  @override
  List<Object> get props => [stepId, stepValidationFunction];
}

class MovePreviousStep extends CreateEventEvent {
  const MovePreviousStep({required this.stepId});

  final String stepId;

  @override
  List<Object> get props => [stepId];
}

class EventStartDateChanged extends CreateEventEvent {
  const EventStartDateChanged({required this.eventStartDate});

  final DateTime eventStartDate;

  @override
  List<Object> get props => [eventStartDate];
}

class EventStartTimeChanged extends CreateEventEvent {
  const EventStartTimeChanged({required this.eventStartTime});

  final TimeOfDay eventStartTime;

  @override
  List<Object> get props => [eventStartTime];
}

class EventDurationChanged extends CreateEventEvent {
  const EventDurationChanged({required this.durationHours});

  final int durationHours;

  @override
  List<Object> get props => [durationHours];
}

class EventLocationChanged extends CreateEventEvent {
  const EventLocationChanged({required this.eventLocation});

  final String eventLocation;

  @override
  List<Object> get props => [eventLocation];
}
