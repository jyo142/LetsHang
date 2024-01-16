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
    on<LoadEventPolls>((event, emit) async {
      emit(state.copyWith(
          hangEventPollsStateStatus:
              HangEventPollsStateStatus.loadingEventPolls));
      emit(await _mapLoadEventPolls(event.eventId));
    });
  }

  Future<HangEventPollsState> _mapLoadEventPolls(String eventId) async {
    try {
      List<HangEventPoll>? retrievedActiveEventPolls =
          await _eventPollRepository.getActiveEventPolls(eventId);

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
