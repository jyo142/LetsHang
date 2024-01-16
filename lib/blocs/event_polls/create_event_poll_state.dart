part of 'create_event_poll_bloc.dart';

enum CreateEventPollStateStatus {
  initial,
  submittingCreatePoll,
  successfullyCreatedPoll,
  error
}

class CreateEventPollState extends Equatable {
  final CreateEventPollStateStatus createEventPollStateStatus;
  final HangUserPreview? creatingUser;
  final String? pollName;
  final String? addNewPollOption;
  final List<String> pollOptions;
  final String? errorMessage;

  const CreateEventPollState(
      {required this.createEventPollStateStatus,
      this.creatingUser,
      this.pollName,
      this.addNewPollOption,
      this.pollOptions = const [],
      this.errorMessage});

  CreateEventPollState copyWith(
      {CreateEventPollStateStatus? createEventPollStateStatus,
      HangUserPreview? creatingUser,
      String? pollName,
      String? addNewPollOption,
      List<String>? pollOptions,
      String? errorMessage}) {
    return CreateEventPollState(
        createEventPollStateStatus:
            createEventPollStateStatus ?? this.createEventPollStateStatus,
        creatingUser: creatingUser ?? this.creatingUser,
        pollName: pollName ?? this.pollName,
        addNewPollOption: addNewPollOption ?? this.addNewPollOption,
        pollOptions: pollOptions ?? this.pollOptions,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  CreateEventPollState addPollOption(String newPollOption) {
    final newPollOptions = List.of(pollOptions);
    newPollOptions.add(newPollOption);
    return copyWith(pollOptions: newPollOptions);
  }

  CreateEventPollState removePollOption(int pollOptionIndex) {
    final newPollOptions = List.of(pollOptions);
    newPollOptions.removeAt(pollOptionIndex);
    return copyWith(pollOptions: newPollOptions);
  }

  @override
  List<Object?> get props => [
        createEventPollStateStatus,
        creatingUser,
        pollName,
        addNewPollOption,
        pollOptions,
        errorMessage
      ];
}
