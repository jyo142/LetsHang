part of 'create_event_bloc.dart';

abstract class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object> get props => [];
}

class LoadEventStep extends CreateEventEvent {}

class InitializeGroup extends CreateEventEvent {
  const InitializeGroup({required this.groupId});

  final String groupId;

  @override
  List<Object> get props => [groupId];
}

// used if an event is already created and want to continue event creation.
// need to load the previous details
class LoadCurrentEventDetails extends CreateEventEvent {
  const LoadCurrentEventDetails({required this.eventId});

  final String eventId;

  @override
  List<Object> get props => [eventId];
}

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

class MoveExactStage extends CreateEventEvent {
  const MoveExactStage({required this.eventStage});

  final HangEventStage eventStage;

  @override
  List<Object> get props => [eventStage];
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

class EventLocationKnownChanged extends CreateEventEvent {
  const EventLocationKnownChanged({required this.eventLocationKnown});

  final CreateEventYesNo eventLocationKnown;

  @override
  List<Object> get props => [eventLocationKnown];
}

class EventLocationChanged extends CreateEventEvent {
  const EventLocationChanged({required this.eventLocation});

  final String eventLocation;

  @override
  List<Object> get props => [eventLocation];
}

class IsRecurringEventChanged extends CreateEventEvent {
  const IsRecurringEventChanged(
      {required this.stepId,
      required this.isRecurringEvent,
      required this.fieldName});

  final String stepId;
  final CreateEventYesNo isRecurringEvent;
  final String fieldName;

  @override
  List<Object> get props => [stepId, isRecurringEvent, fieldName];
}

class RecurringTypeChanged extends CreateEventEvent {
  const RecurringTypeChanged({required this.recurringType});

  final HangEventRecurringType recurringType;

  @override
  List<Object> get props => [recurringType];
}

class RecurringFrequencyChanged extends CreateEventEvent {
  const RecurringFrequencyChanged({required this.recurringFrequency});

  final int recurringFrequency;

  @override
  List<Object> get props => [recurringFrequency];
}
