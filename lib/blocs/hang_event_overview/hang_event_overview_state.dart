part of 'hang_event_overview_bloc.dart';

enum HangEventOverviewStateStatus {
  initial,
  loading,
  hangEventsRetrieved,
  individualEventRetrieved,
  error
}

@immutable
class HangEventOverviewState extends Equatable {
  final HangEventOverviewStateStatus hangEventOverviewStateStatus;
  final String? errorMessage;
  final HangEvent? individualHangEvent;
  final List<HangEventInvite> hangEvents;
  final List<HangEventInvite> pastHangEvents;
  final List<HangEventInvite> upcomingHangEvents;
  final List<HangEventInvite> draftUpcomingHangEvents;
  final Map<String, List<HangEventInvite>> dateToEvents;
  const HangEventOverviewState(
      {required this.hangEventOverviewStateStatus,
      this.errorMessage,
      this.individualHangEvent,
      this.hangEvents = const [],
      this.pastHangEvents = const [],
      this.upcomingHangEvents = const [],
      this.draftUpcomingHangEvents = const [],
      this.dateToEvents = const {}});

  HangEventOverviewState copyWith(
      {HangEventOverviewStateStatus? hangEventOverviewStateStatus,
      HangEvent? individualHangEvent,
      String? errorMessage,
      List<HangEventInvite>? hangEvents,
      List<HangEventInvite>? pastHangEvents,
      List<HangEventInvite>? upcomingHangEvents,
      List<HangEventInvite>? draftUpcomingHangEvents,
      Map<String, List<HangEventInvite>>? dateToEvents}) {
    return HangEventOverviewState(
        hangEventOverviewStateStatus:
            hangEventOverviewStateStatus ?? this.hangEventOverviewStateStatus,
        individualHangEvent: individualHangEvent ?? this.individualHangEvent,
        hangEvents: hangEvents ?? this.hangEvents,
        pastHangEvents: pastHangEvents ?? this.pastHangEvents,
        upcomingHangEvents: upcomingHangEvents ?? this.upcomingHangEvents,
        draftUpcomingHangEvents:
            draftUpcomingHangEvents ?? this.draftUpcomingHangEvents,
        dateToEvents: dateToEvents ?? this.dateToEvents,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  HangEventOverviewState eventsRetrieved() {
    final dateNow = DateTime.now();
    // past events are when the current date is after both the start and end date of the event
    List<HangEventInvite> pastHangEvents = hangEvents
        .where((element) =>
            element.eventStartDateTime != null &&
            element.eventEndDateTime != null &&
            dateNow.isAfter(element.eventStartDateTime!) &&
            dateNow.isAfter(element.eventEndDateTime!))
        .toList();

    List<HangEventInvite> upcomingHangEvents = hangEvents
        .where((element) =>
            element.eventStartDateTime != null &&
            (dateNow.compareTo(element.eventStartDateTime!) <= 0))
        .toList();

    Map<String, List<HangEventInvite>> dateToEvents = {
      for (HangEventInvite item in upcomingHangEvents)
        DateFormat('MM/dd/yyyy').format(item.eventStartDateTime!): [item]
    };
    List<HangEventInvite> draftUpcomingHangEvents = hangEvents
        .where((element) =>
            element.eventStartDateTime == null ||
            element.eventEndDateTime == null ||
            element.status == InviteStatus.incomplete ||
            dateNow.compareTo(element.eventStartDateTime!) <= 0 ||
            dateNow.compareTo(element.eventEndDateTime!) <= 0)
        .toList();

    return copyWith(
        pastHangEvents: pastHangEvents,
        upcomingHangEvents: upcomingHangEvents,
        dateToEvents: dateToEvents,
        draftUpcomingHangEvents: draftUpcomingHangEvents);
  }

  @override
  List<Object?> get props => [
        hangEventOverviewStateStatus,
        errorMessage,
        individualHangEvent,
        hangEvents,
        pastHangEvents,
        upcomingHangEvents,
        draftUpcomingHangEvents,
        dateToEvents
      ];
}
