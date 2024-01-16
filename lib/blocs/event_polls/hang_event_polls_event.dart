part of 'hang_event_polls_bloc.dart';

abstract class HangEventPollsEvent extends Equatable {
  const HangEventPollsEvent();

  @override
  List<Object> get props => [];
}

class LoadEventPolls extends HangEventPollsEvent {
  final String eventId;

  const LoadEventPolls({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
