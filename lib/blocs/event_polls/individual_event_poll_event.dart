part of 'individual_event_poll_bloc.dart';

abstract class IndividualEventPollEvent extends Equatable {
  const IndividualEventPollEvent();

  @override
  List<Object> get props => [];
}

class LoadIndividualPollResults extends IndividualEventPollEvent {
  final String eventId;
  final String pollId;

  const LoadIndividualPollResults(
      {required this.eventId, required this.pollId});

  @override
  List<Object> get props => [eventId, pollId];
}

class SubmitPollVote extends IndividualEventPollEvent {
  final String eventId;
  final String pollId;
  final String pollOption;
  final HangUserPreview submittingUser;

  const SubmitPollVote(
      {required this.eventId,
      required this.pollId,
      required this.pollOption,
      required this.submittingUser});

  @override
  List<Object> get props => [eventId, pollId, pollOption, submittingUser];
}

class ResetPollVote extends IndividualEventPollEvent {
  final String eventId;
  final String pollId;
  final String pollResultId;

  const ResetPollVote(
      {required this.eventId,
      required this.pollId,
      required this.pollResultId});

  @override
  List<Object> get props => [eventId, pollId, pollResultId];
}
