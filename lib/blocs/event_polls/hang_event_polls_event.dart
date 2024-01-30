part of 'hang_event_polls_bloc.dart';

abstract class HangEventPollsEvent extends Equatable {
  const HangEventPollsEvent();

  @override
  List<Object> get props => [];
}

class LoadIndividualEventPoll extends HangEventPollsEvent {
  final String eventId;
  final String eventPollId;
  const LoadIndividualEventPoll(
      {required this.eventId, required this.eventPollId});

  @override
  List<Object> get props => [eventId, eventPollId];
}

class LoadEventPolls extends HangEventPollsEvent {
  final String eventId;
  final String userId;

  const LoadEventPolls({required this.eventId, required this.userId});

  @override
  List<Object> get props => [eventId, userId];
}
