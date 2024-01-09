part of 'hang_event_responsibilities_bloc.dart';

abstract class HangEventResponsibilitiesEvent extends Equatable {
  const HangEventResponsibilitiesEvent();

  @override
  List<Object> get props => [];
}

class LoadEventResponsibilities extends HangEventResponsibilitiesEvent {
  final String eventId;

  const LoadEventResponsibilities({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class LoadUserEventResponsibilities extends HangEventResponsibilitiesEvent {
  final String eventId;
  final String userId;

  const LoadUserEventResponsibilities(
      {required this.eventId, required this.userId});

  @override
  List<Object> get props => [eventId, userId];
}

class CompleteEventResponsibility extends HangEventResponsibilitiesEvent {
  final String eventId;
  final HangEventResponsibility eventResponsibility;

  const CompleteEventResponsibility(
      {required this.eventId, required this.eventResponsibility});

  @override
  List<Object> get props => [eventId, eventResponsibility];
}
