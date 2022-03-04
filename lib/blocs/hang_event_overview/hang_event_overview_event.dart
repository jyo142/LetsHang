part of 'hang_event_overview_bloc.dart';

@immutable
abstract class HangEventOverviewEvent extends Equatable {
  const HangEventOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadHangEvents extends HangEventOverviewEvent {}

class UpdateHangEvents extends HangEventOverviewEvent {
  final List<HangEvent> hangEvents;

  const UpdateHangEvents(this.hangEvents);

  @override
  List<Object> get props => [hangEvents];
}
