import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'user_hang_event_title_event.dart';
part 'user_hang_event_title_state.dart';

class UserHangEventTitleBloc
    extends Bloc<UserHangEventTitleEvent, UserHangEventTitleState> {
  final BaseUserInvitesRepository _userInvitesRepository;
  // constructor
  UserHangEventTitleBloc()
      : _userInvitesRepository = UserInvitesRepository(),
        super(const UserHangEventTitleState(
            userHangEventTitleStateStatus:
                UserHangEventTitleStateStatus.initial)) {
    on<GetUserEventTitle>((event, emit) async {
      emit(state.copyWith(
          userHangEventTitleStateStatus:
              UserHangEventTitleStateStatus.loading));
      emit(await _mapLoadUserEventTitle(
        eventId: event.eventId,
        userId: event.userId,
      ));
    });
  }

  Future<UserHangEventTitleState> _mapLoadUserEventTitle({
    required String userId,
    required String eventId,
  }) async {
    try {
      HangEventInvite? userInviteForEvent =
          await _userInvitesRepository.getUserInviteForEvent(userId, eventId);
      if (userInviteForEvent == null) {
        return state.copyWith(
            userHangEventTitleStateStatus: UserHangEventTitleStateStatus.error,
            errorMessage: "Unable to get user's role for the event");
      }
      return state.copyWith(
          userHangEventTitleStateStatus:
              UserHangEventTitleStateStatus.retrievedUserEventTitle,
          userEventTitle: userInviteForEvent.title);
    } catch (e) {
      return state.copyWith(
          userHangEventTitleStateStatus: UserHangEventTitleStateStatus.error,
          errorMessage: "Unable to get user's role for the event");
    }
  }
}
