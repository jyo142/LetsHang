part of 'hang_event_polls_bloc.dart';

enum HangEventPollsStateStatus {
  initial,
  loading,
  loadingUserEventPollCount,
  individualEventPollRetrieved,
  retrievedEventPolls,
  retrievedUserEventPollCount,
  error
}

class HangEventPollsState extends Equatable {
  final HangEventPollsStateStatus hangEventPollsStateStatus;
  final HangEventPoll? individualEventPoll;
  final List<HangEventPoll>? activeEventPolls;
  final int? countNewUserPolls;
  final String? errorMessage;

  const HangEventPollsState(
      {required this.hangEventPollsStateStatus,
      this.individualEventPoll,
      this.activeEventPolls,
      this.countNewUserPolls,
      this.errorMessage});

  HangEventPollsState copyWith(
      {HangEventPollsStateStatus? hangEventPollsStateStatus,
      HangEventPoll? individualEventPoll,
      List<HangEventPoll>? activeEventPolls,
      int? countNewUserPolls,
      String? errorMessage}) {
    return HangEventPollsState(
        hangEventPollsStateStatus:
            hangEventPollsStateStatus ?? this.hangEventPollsStateStatus,
        individualEventPoll: individualEventPoll ?? this.individualEventPoll,
        activeEventPolls: activeEventPolls ?? this.activeEventPolls,
        countNewUserPolls: countNewUserPolls ?? this.countNewUserPolls,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        hangEventPollsStateStatus,
        individualEventPoll,
        activeEventPolls,
        countNewUserPolls,
        errorMessage,
      ];
}
