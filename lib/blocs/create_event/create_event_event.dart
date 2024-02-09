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

  final TimeAndDateKnown timeAndDateKnown;

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
