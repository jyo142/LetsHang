part of 'hang_event_overview_bloc.dart';

enum HangEventsScreenTab { pastEvents, upcomingEvents }

@immutable
abstract class HangEventOverviewEvent extends Equatable {
  const HangEventOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadUpcomingEvents extends HangEventOverviewEvent {
  final String userId;

  const LoadUpcomingEvents({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class UpdateHangEventsTab extends HangEventOverviewEvent {
  final HangEventsScreenTab screenTab;
  const UpdateHangEventsTab({required this.screenTab});

  @override
  List<Object> get props => [screenTab];
}

class LoadPastEvents extends HangEventOverviewEvent {
  final String userId;

  const LoadPastEvents({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class LoadHangEvents extends HangEventOverviewEvent {
  final String userId;

  const LoadHangEvents({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class LoadHangEventsForDates extends HangEventOverviewEvent {
  final String userId;
  final DateTime startDateTime;
  final DateTime endDateTime;

  const LoadHangEventsForDates(
      {required this.userId,
      required this.startDateTime,
      required this.endDateTime});

  @override
  List<Object> get props => [userId, endDateTime, endDateTime];
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
