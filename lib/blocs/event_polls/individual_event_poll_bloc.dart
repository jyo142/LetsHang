import 'package:bloc/bloc.dart';
import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/events/hang_event_poll_result.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/polls/base_event_poll_repository.dart';
import 'package:letshang/repositories/polls/event_poll_repository.dart';

part 'individual_event_poll_state.dart';
part 'individual_event_poll_event.dart';

class IndividualEventPollBloc
    extends Bloc<IndividualEventPollEvent, IndividualEventPollState> {
  final BaseEventPollRepository _eventPollRepository;
  final HangEventPoll curEventPoll;
  // constructor
  IndividualEventPollBloc({required this.curEventPoll})
      : _eventPollRepository = EventPollRepository(),
        super(const IndividualEventPollState(
            individualEventPollStateStatus:
                IndividualEventPollStateStatus.initial)) {
    on<LoadIndividualPollResults>((event, emit) async {
      emit(state.copyWith(
          individualEventPollStateStatus:
              IndividualEventPollStateStatus.loading));
      emit(await _mapLoadIndividualPollResults(event.eventId, event.pollId));
    });
    on<SubmitPollVote>((event, emit) async {
      emit(state.copyWith(
          individualEventPollStateStatus:
              IndividualEventPollStateStatus.loading));
      emit(await _mapSubmitPollVote(
          event.eventId, event.pollId, event.pollOption, event.submittingUser));
    });
    on<ResetPollVote>((event, emit) async {
      emit(state.copyWith(
          individualEventPollStateStatus:
              IndividualEventPollStateStatus.loading));
      emit(await _resetPollVote(
          event.eventId, event.pollId, event.pollResultId));
    });
  }

  Future<IndividualEventPollState> _mapLoadIndividualPollResults(
      String eventId, String pollId) async {
    try {
      List<HangEventPollResult> pollResults =
          await _eventPollRepository.getIndividualPollResults(eventId, pollId);

      return state.createPollResults(curEventPoll.pollOptions, pollResults);
    } catch (_) {
      return state.copyWith(
          individualEventPollStateStatus: IndividualEventPollStateStatus.error,
          errorMessage: 'Unable to retrieve poll results for event.');
    }
  }

  Future<IndividualEventPollState> _mapSubmitPollVote(String eventId,
      String pollId, String pollOption, HangUserPreview submittingUser) async {
    try {
      HangEventPollResult pollResult = HangEventPollResult(
          pollUser: submittingUser,
          creationDate: DateTime.now(),
          pollId: pollId,
          pollResult: pollOption);

      await _eventPollRepository.addPollResult(eventId, pollResult);

      return state.copyWith(
          individualEventPollStateStatus:
              IndividualEventPollStateStatus.submitPollResultSuccessfully);
    } catch (_) {
      return state.copyWith(
          individualEventPollStateStatus: IndividualEventPollStateStatus.error,
          errorMessage: 'Unable to retrieve poll results for event.');
    }
  }

  Future<IndividualEventPollState> _resetPollVote(
      String eventId, String pollId, String pollResultId) async {
    try {
      await _eventPollRepository.removePollResult(
          eventId, pollId, pollResultId);

      return state.copyWith(
          individualEventPollStateStatus:
              IndividualEventPollStateStatus.resetPollVoteSuccessfully);
    } catch (_) {
      return state.copyWith(
          individualEventPollStateStatus: IndividualEventPollStateStatus.error,
          errorMessage: 'Unable to reset poll result for event.');
    }
  }
}
