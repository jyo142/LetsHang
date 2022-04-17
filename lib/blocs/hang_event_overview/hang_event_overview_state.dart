part of 'hang_event_overview_bloc.dart';

@immutable
abstract class HangEventOverviewState extends Equatable {
  const HangEventOverviewState();

  @override
  List<Object> get props => [];
}

class HangEventsLoading extends HangEventOverviewState {}

class HangEventsRetrieved extends HangEventOverviewState {
  late final List<HangEvent> hangEvents;
  late final List<HangEvent> pastHangEvents;
  late final List<HangEvent> currentUpcomingHangEvents;

  HangEventsRetrieved({this.hangEvents = const <HangEvent>[]}) {
    final dateNow = DateTime.now();
    // past events are when the current date is after both the start and end date of the event
    pastHangEvents = hangEvents
        .where((element) =>
            dateNow.isAfter(element.eventStartDate) &&
            dateNow.isAfter(element.eventEndDate))
        .toList();

    currentUpcomingHangEvents = hangEvents
        .where((element) =>
            dateNow.compareTo(element.eventStartDate) <= 0 ||
            dateNow.compareTo(element.eventEndDate) <= 0)
        .toList();
  }

  @override
  List<Object> get props => [hangEvents];
}
