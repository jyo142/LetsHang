import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:letshang/repositories/polls/base_event_poll_repository.dart';
import 'package:letshang/repositories/polls/event_poll_repository.dart';
import 'package:letshang/repositories/responsibilities/base_responsibilities_repository.dart';
import 'package:letshang/repositories/responsibilities/responsibilities_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'user_hang_event_status_event.dart';
part 'user_hang_event_status_state.dart';

class UserHangEventStatusBloc
    extends Bloc<UserHangEventStatusEvent, UserEventStatusState> {
  final BaseEventPollRepository _eventPollRepository;
  final BaseResponsibilitiesRepository _responsibilitiesRepository;
  final BaseUserInvitesRepository _userInvitesRepository;
  // constructor
  UserHangEventStatusBloc()
      : _eventPollRepository = EventPollRepository(),
        _responsibilitiesRepository = ResponsibilitiesRepository(),
        _userInvitesRepository = UserInvitesRepository(),
        super(const UserEventStatusState(
            userEventStatusStateStatus: UserEventStatusStateStatus.initial)) {
    on<GetUserEventStatus>((event, emit) async {
      emit(state.copyWith(
          userEventStatusStateStatus: UserEventStatusStateStatus.loading));
      emit(await _mapLoadUserEventIncompleteStatus(
        eventId: event.eventId,
        userId: event.userId,
      ));
    });
  }

  Future<UserEventStatusState> _mapLoadUserEventIncompleteStatus({
    required String userId,
    required String eventId,
  }) async {
    int pollIncompleteCount = await getStatusCount((userId, eventId) async {
      return await _responsibilitiesRepository
          .getNonCompletedUserResponsibilityCount(eventId, userId);
    }, userId, eventId);
    int responsibilityIncompleteCount =
        await getStatusCount((userId, eventId) async {
      return await _eventPollRepository.getNonCompletedUserPollCount(
          eventId, userId);
    }, userId, eventId);
    int eventParticipantsCount = await getStatusCount((userId, eventId) async {
      return await _userInvitesRepository
          .getEventAcceptedUserInvitesCount(eventId);
    }, userId, eventId);
    return state.copyWith(
        userEventStatusStateStatus:
            UserEventStatusStateStatus.retrievedUserIncompleteStatus,
        incompletePollCount: pollIncompleteCount,
        incompleteResponsibilitiesCount: responsibilityIncompleteCount,
        eventParticipantsCount: eventParticipantsCount,
        hasIncomplete:
            pollIncompleteCount > 0 || responsibilityIncompleteCount > 0);
  }

  Future<int> getStatusCount(Future<int> Function(String, String) getCountFunc,
      String userId, String eventId) async {
    try {
      return getCountFunc(userId, eventId);
    } catch (_) {
      // log exception
      return 0;
    }
  }
}
