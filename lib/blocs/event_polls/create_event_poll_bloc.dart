import 'package:bloc/bloc.dart';
import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/polls/base_event_poll_repository.dart';
import 'package:letshang/repositories/polls/event_poll_repository.dart';

part 'create_event_poll_state.dart';
part 'create_event_poll_event.dart';

class CreateEventPollBloc
    extends Bloc<CreateEventPollEvent, CreateEventPollState> {
  final BaseEventPollRepository _eventPollRepository;
  // constructor
  CreateEventPollBloc()
      : _eventPollRepository = EventPollRepository(),
        super(const CreateEventPollState(
            createEventPollStateStatus: CreateEventPollStateStatus.initial)) {
    on<PollNameChanged>((event, emit) async {
      emit(state.copyWith(pollName: event.pollName));
    });
    on<AddPollOption>((event, emit) async {
      emit(state.addPollOption(event.newPollOption));
    });
    on<ChangeAddNewPoll>((event, emit) async {
      emit(state.copyWith(addNewPollOption: event.newPollOption));
    });
    on<RemovePollOption>((event, emit) async {
      emit(state.removePollOption(event.pollOptionIndex));
    });
    on<SubmitCreatePoll>((event, emit) async {
      emit(state.copyWith(
          createEventPollStateStatus:
              CreateEventPollStateStatus.submittingCreatePoll));
      emit(await _mapAddEventPoll(event.eventId, event.creatingUser));
    });
  }

  Future<CreateEventPollState> _mapAddEventPoll(
      String eventId, HangUserPreview creatingUser) async {
    try {
      await _eventPollRepository.addEventPoll(
          eventId,
          HangEventPoll(
              pollName: state.pollName!,
              pollOptions: state.pollOptions,
              creationDate: DateTime.now(),
              creatingUser: creatingUser));

      return state.copyWith(
          createEventPollStateStatus:
              CreateEventPollStateStatus.successfullyCreatedPoll);
    } catch (_) {
      return state.copyWith(
          createEventPollStateStatus: CreateEventPollStateStatus.error,
          errorMessage: 'Unable to save poll for event.');
    }
  }
}
