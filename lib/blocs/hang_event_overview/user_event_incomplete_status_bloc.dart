import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/repositories/polls/base_event_poll_repository.dart';
import 'package:letshang/repositories/polls/event_poll_repository.dart';
import 'package:letshang/repositories/responsibilities/base_responsibilities_repository.dart';
import 'package:letshang/repositories/responsibilities/responsibilities_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'user_event_incomplete_status_event.dart';
part 'user_event_incomplete_status_state.dart';

class UserEventIncompleteStatusBloc extends Bloc<UserEventIncompleteStatusEvent,
    UserEventIncompleteStatusState> {
  final BaseEventPollRepository _eventPollRepository;
  final BaseResponsibilitiesRepository _responsibilitiesRepository;

  // constructor
  UserEventIncompleteStatusBloc()
      : _eventPollRepository = EventPollRepository(),
        _responsibilitiesRepository = ResponsibilitiesRepository(),
        super(const UserEventIncompleteStatusState(
            userEventIncompleteStatusStateStatus:
                UserEventIncompleteStatusStateStatus.initial)) {
    on<GetUserEventIncompleteStatus>((event, emit) async {
      emit(state.copyWith(
          userEventIncompleteStatusStateStatus:
              UserEventIncompleteStatusStateStatus.loading));
      emit(await _mapLoadUserEventIncompleteStatus(
        eventId: event.eventId,
        userId: event.userId,
      ));
    });
  }

  Future<UserEventIncompleteStatusState> _mapLoadUserEventIncompleteStatus({
    required String userId,
    required String eventId,
  }) async {
    int pollIncompleteCount = await getIncompleteCount((userId, eventId) async {
      return await _responsibilitiesRepository
          .getNonCompletedUserResponsibilityCount(eventId, userId);
    }, userId, eventId);
    int responsibilityIncompleteCount =
        await getIncompleteCount((userId, eventId) async {
      return await _eventPollRepository.getNonCompletedUserPollCount(
          eventId, userId);
    }, userId, eventId);
    return state.copyWith(
        userEventIncompleteStatusStateStatus:
            UserEventIncompleteStatusStateStatus.retrievedUserIncompleteStatus,
        incompletePollCount: pollIncompleteCount,
        incompleteResponsibilitiesCount: responsibilityIncompleteCount,
        hasIncomplete:
            pollIncompleteCount > 0 || responsibilityIncompleteCount > 0);
  }

  Future<int> getIncompleteCount(
      Future<int> Function(String, String) getCountFunc,
      String userId,
      String eventId) async {
    try {
      return getCountFunc(userId, eventId);
    } catch (_) {
      // log exception
      return 0;
    }
  }
}
