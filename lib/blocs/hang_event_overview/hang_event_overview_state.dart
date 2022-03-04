part of 'hang_event_overview_bloc.dart';

@immutable
abstract class HangEventOverviewState extends Equatable {
  const HangEventOverviewState();

  @override
  List<Object> get props => [];
}

class HangEventsLoading extends HangEventOverviewState {}

class HangEventsRetrieved extends HangEventOverviewState {
  final List<HangEvent> hangEvents;

  HangEventsRetrieved({this.hangEvents = const <HangEvent>[]});

  @override
  List<Object> get props => [hangEvents];
}
