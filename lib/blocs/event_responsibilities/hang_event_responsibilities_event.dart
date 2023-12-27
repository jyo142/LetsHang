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
