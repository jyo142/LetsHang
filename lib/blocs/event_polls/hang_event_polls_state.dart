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
  final List<HangEventPollWithResultCount>? allEventPolls;
  final String? errorMessage;

  const HangEventPollsState(
      {required this.hangEventPollsStateStatus,
      this.individualEventPoll,
      this.allEventPolls,
      this.errorMessage});

  HangEventPollsState copyWith(
      {HangEventPollsStateStatus? hangEventPollsStateStatus,
      HangEventPoll? individualEventPoll,
      List<HangEventPollWithResultCount>? allEventPolls,
      String? errorMessage}) {
    return HangEventPollsState(
        hangEventPollsStateStatus:
            hangEventPollsStateStatus ?? this.hangEventPollsStateStatus,
        individualEventPoll: individualEventPoll ?? this.individualEventPoll,
        allEventPolls: allEventPolls ?? this.allEventPolls,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        hangEventPollsStateStatus,
        individualEventPoll,
        allEventPolls,
        errorMessage,
      ];
}
