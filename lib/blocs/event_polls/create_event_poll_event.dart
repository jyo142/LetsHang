part of 'create_event_poll_bloc.dart';

abstract class CreateEventPollEvent extends Equatable {
  const CreateEventPollEvent();

  @override
  List<Object> get props => [];
}

class PollNameChanged extends CreateEventPollEvent {
  final String pollName;

  const PollNameChanged({required this.pollName});

  @override
  List<Object> get props => [pollName];
}

class ChangeAddNewPoll extends CreateEventPollEvent {
  final String newPollOption;

  const ChangeAddNewPoll({required this.newPollOption});

  @override
  List<Object> get props => [newPollOption];
}

class AddPollOption extends CreateEventPollEvent {
  final String newPollOption;

  const AddPollOption({required this.newPollOption});

  @override
  List<Object> get props => [newPollOption];
}

class RemovePollOption extends CreateEventPollEvent {
  final int pollOptionIndex;

  const RemovePollOption({required this.pollOptionIndex});

  @override
  List<Object> get props => [pollOptionIndex];
}

class SubmitCreatePoll extends CreateEventPollEvent {
  final String eventId;

  const SubmitCreatePoll({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
