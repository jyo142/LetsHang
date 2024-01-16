part of 'individual_event_poll_bloc.dart';

enum IndividualEventPollStateStatus {
  initial,
  loading,
  retrievedIndividualPollResults,
  submittingPollResult,
  submitPollResultSuccessfully,
  resetPollVoteSuccessfully,
  error
}

class IndividualEventPollState extends Equatable {
  final IndividualEventPollStateStatus individualEventPollStateStatus;
  final HangEventPoll? eventPoll;
  final List<PollOptionToResults> pollOptionToResults;
  final String? errorMessage;
  final Map<String, HangEventPollResult>? userIdToPollResult;

  const IndividualEventPollState(
      {required this.individualEventPollStateStatus,
      this.eventPoll,
      this.pollOptionToResults = const [],
      this.errorMessage,
      this.userIdToPollResult});

  IndividualEventPollState copyWith(
      {IndividualEventPollStateStatus? individualEventPollStateStatus,
      HangEventPoll? eventPoll,
      List<PollOptionToResults>? pollOptionToResults,
      Map<String, HangEventPollResult>? userIdToPollResult,
      String? errorMessage}) {
    return IndividualEventPollState(
        individualEventPollStateStatus: individualEventPollStateStatus ??
            this.individualEventPollStateStatus,
        eventPoll: eventPoll ?? this.eventPoll,
        pollOptionToResults: pollOptionToResults ?? this.pollOptionToResults,
        userIdToPollResult: userIdToPollResult ?? this.userIdToPollResult,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  IndividualEventPollState createPollResults(
      List<String> pollOptions, List<HangEventPollResult> pollResults) {
    List<PollOptionToResults> result = [];
    for (String curPollOption in pollOptions) {
      List<HangEventPollResult> foundPollOptionResult = pollResults
          .where((element) => element.pollResult == curPollOption)
          .toList();
      result.add(PollOptionToResults(
          pollOption: curPollOption, pollResults: foundPollOptionResult));
    }

    Map<String, HangEventPollResult> userIdPollResult =
        <String, HangEventPollResult>{};
    for (HangEventPollResult curResult in pollResults) {
      userIdPollResult.putIfAbsent(curResult.pollUser.userId, () => curResult);
    }
    return copyWith(
        pollOptionToResults: result,
        userIdToPollResult: userIdPollResult,
        individualEventPollStateStatus:
            IndividualEventPollStateStatus.retrievedIndividualPollResults);
  }

  @override
  List<Object?> get props =>
      [individualEventPollStateStatus, eventPoll, errorMessage];
}
