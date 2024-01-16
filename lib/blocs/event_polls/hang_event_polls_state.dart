part of 'hang_event_polls_bloc.dart';

enum HangEventPollsStateStatus {
  initial,
  loadingEventPolls,
  retrievedEventPolls,
  error
}

class HangEventPollsState extends Equatable {
  final HangEventPollsStateStatus hangEventPollsStateStatus;
  final List<HangEventPoll>? activeEventPolls;
  final String? errorMessage;

  const HangEventPollsState(
      {required this.hangEventPollsStateStatus,
      this.activeEventPolls,
      this.errorMessage});

  HangEventPollsState copyWith(
      {HangEventPollsStateStatus? hangEventPollsStateStatus,
      List<HangEventPoll>? activeEventPolls,
      String? errorMessage}) {
    return HangEventPollsState(
        hangEventPollsStateStatus:
            hangEventPollsStateStatus ?? this.hangEventPollsStateStatus,
        activeEventPolls: activeEventPolls ?? this.activeEventPolls,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        hangEventPollsStateStatus,
        activeEventPolls,
        errorMessage,
      ];
}
