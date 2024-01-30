import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/repositories/polls/base_event_poll_repository.dart';
import 'package:letshang/repositories/polls/event_poll_repository.dart';

part 'hang_event_polls_state.dart';
part 'hang_event_polls_event.dart';

class HangEventPollsBloc
    extends Bloc<HangEventPollsEvent, HangEventPollsState> {
  final BaseEventPollRepository _eventPollRepository;
  // constructor
  HangEventPollsBloc()
      : _eventPollRepository = EventPollRepository(),
        super(const HangEventPollsState(
            hangEventPollsStateStatus: HangEventPollsStateStatus.initial)) {
    on<LoadIndividualEventPoll>((event, emit) async {
      emit(state.copyWith(
          hangEventPollsStateStatus: HangEventPollsStateStatus.loading));
      emit(await _mapLoadIndividualEventPoll(event.eventId, event.eventPollId));
    });
    on<LoadEventPolls>((event, emit) async {
      emit(state.copyWith(
          hangEventPollsStateStatus: HangEventPollsStateStatus.loading));
      emit(await _mapLoadEventPolls(event.eventId, event.userId));
    });
  }

  Future<HangEventPollsState> _mapLoadIndividualEventPoll(
      String eventId, String eventPollId) async {
    try {
      HangEventPoll? retrievedEventPoll =
          await _eventPollRepository.getIndividualPoll(eventId, eventPollId);
      if (retrievedEventPoll != null) {
        return state.copyWith(
          hangEventPollsStateStatus:
              HangEventPollsStateStatus.individualEventPollRetrieved,
          individualEventPoll: retrievedEventPoll,
        );
      } else {
        return state.copyWith(
            hangEventPollsStateStatus: HangEventPollsStateStatus.error,
            errorMessage: 'Unable to find event poll');
      }
    } catch (_) {
      return state.copyWith(
          hangEventPollsStateStatus: HangEventPollsStateStatus.error,
          errorMessage: 'Unable to retrieve poll for event.');
    }
  }

  Future<HangEventPollsState> _mapLoadEventPolls(
      String eventId, String userId) async {
    try {
      List<HangEventPollWithResultCount>? retrievedActiveEventPolls =
          await _eventPollRepository.getActiveEventPollsWithResultCount(
              eventId, userId);

      return state.copyWith(
        hangEventPollsStateStatus:
            HangEventPollsStateStatus.retrievedEventPolls,
        activeEventPolls: retrievedActiveEventPolls,
      );
    } catch (_) {
      return state.copyWith(
          hangEventPollsStateStatus: HangEventPollsStateStatus.error,
          errorMessage: 'Unable to get polls for event.');
    }
  }
}
