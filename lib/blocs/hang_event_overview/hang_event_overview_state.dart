part of 'hang_event_overview_bloc.dart';

@immutable
abstract class HangEventOverviewState extends Equatable {
  const HangEventOverviewState();

  @override
  List<Object> get props => [];
}

class HangEventsLoading extends HangEventOverviewState {}

class IndividualEventLoading extends HangEventOverviewState {}

class IndividualEventRetrieved extends HangEventOverviewState {
  final HangEvent hangEvent;

  const IndividualEventRetrieved({required this.hangEvent});

  @override
  List<Object> get props => [hangEvent];
}

class IndividualEventRetrievedError extends HangEventOverviewState {
  final String errorMessage;

  const IndividualEventRetrievedError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class HangEventsRetrieved extends HangEventOverviewState {
  late final List<HangEventInvite> hangEvents;
  late final List<HangEventInvite> pastHangEvents;
  late final List<HangEventInvite> upcomingHangEvents;
  late final List<HangEventInvite> draftUpcomingHangEvents;
  late final Map<String, List<HangEventInvite>> dateToEvents;
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

    upcomingHangEvents = hangEvents
        .where((element) =>
            element.event.eventStartDate != null &&
            (dateNow.compareTo(element.event.eventStartDate!) <= 0))
        .toList();

    dateToEvents = {
      for (HangEventInvite item in upcomingHangEvents)
        DateFormat('MM/dd/yyyy').format(item.eventStartDateTime!): [item]
    };
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
  List<Object> get props => [
        hangEvents,
        pastHangEvents,
        upcomingHangEvents,
        draftUpcomingHangEvents,
        dateToEvents
      ];
}
