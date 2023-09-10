part of 'hang_event_overview_bloc.dart';

@immutable
abstract class HangEventOverviewEvent extends Equatable {
  const HangEventOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadHangEvents extends HangEventOverviewEvent {
  final String userEmail;

  const LoadHangEvents({
    required this.userEmail,
  });

  @override
  List<Object> get props => [userEmail];
}

class LoadHangEventsForDates extends HangEventOverviewEvent {
  final String userEmail;
  final DateTime startDateTime;
  final DateTime endDateTime;

  const LoadHangEventsForDates(
      {required this.userEmail,
      required this.startDateTime,
      required this.endDateTime});

  @override
  List<Object> get props => [userEmail, endDateTime, endDateTime];
}

class UpdateHangEvents extends HangEventOverviewEvent {
  final List<HangEvent> hangEvents;

  const UpdateHangEvents(this.hangEvents);

  @override
  List<Object> get props => [hangEvents];
}

class LoadIndividualEvent extends HangEventOverviewEvent {
  final String eventId;

  const LoadIndividualEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
