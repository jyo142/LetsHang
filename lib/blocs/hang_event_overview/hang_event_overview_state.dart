part of 'hang_event_overview_bloc.dart';

@immutable
abstract class HangEventOverviewState extends Equatable {
  const HangEventOverviewState();

  @override
  List<Object> get props => [];
}

class HangEventsLoading extends HangEventOverviewState {}

class HangEventsRetrieved extends HangEventOverviewState {
  late final List<HangEventInvite> hangEvents;
  late final List<HangEventInvite> pastHangEvents;
  late final List<HangEventInvite> draftUpcomingHangEvents;

  HangEventsRetrieved({this.hangEvents = const <HangEventInvite>[]}) {
    final dateNow = DateTime.now();
    // past events are when the current date is after both the start and end date of the event
    pastHangEvents = hangEvents
        .where((element) =>
            element.event.eventStartDate != null &&
            element.event.eventEndDate != null &&
            dateNow.isAfter(element.event.eventStartDate!) &&
            dateNow.isAfter(element.event.eventEndDate!))
        .toList();

    draftUpcomingHangEvents = hangEvents
        .where((element) =>
            element.event.eventStartDate == null ||
            element.event.eventEndDate == null ||
            element.status == InviteStatus.incomplete ||
            dateNow.compareTo(element.event.eventStartDate!) <= 0 ||
            dateNow.compareTo(element.event.eventEndDate!) <= 0)
        .toList();
  }

  @override
  List<Object> get props => [hangEvents];
}
