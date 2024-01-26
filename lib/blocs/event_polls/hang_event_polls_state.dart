part of 'hang_event_polls_bloc.dart';

enum HangEventPollsStateStatus {
  initial,
  loading,
  individualEventPollRetrieved,
  retrievedEventPolls,
  error
}

class HangEventPollsState extends Equatable {
  final HangEventPollsStateStatus hangEventPollsStateStatus;
  final HangEventPoll? individualEventPoll;
  final List<HangEventPoll>? activeEventPolls;
  final String? errorMessage;

  const HangEventPollsState(
      {required this.hangEventPollsStateStatus,
      this.individualEventPoll,
      this.activeEventPolls,
      this.errorMessage});

  HangEventPollsState copyWith(
      {HangEventPollsStateStatus? hangEventPollsStateStatus,
      HangEventPoll? individualEventPoll,
      List<HangEventPoll>? activeEventPolls,
      String? errorMessage}) {
    return HangEventPollsState(
        hangEventPollsStateStatus:
            hangEventPollsStateStatus ?? this.hangEventPollsStateStatus,
        individualEventPoll: individualEventPoll ?? this.individualEventPoll,
        activeEventPolls: activeEventPolls ?? this.activeEventPolls,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        hangEventPollsStateStatus,
        individualEventPoll,
        activeEventPolls,
        errorMessage,
      ];
}
