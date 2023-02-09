import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_participants.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'hang_event_participants_event.dart';
part 'hang_event_participants_state.dart';

class HangEventParticipantsBloc
    extends Bloc<HangEventParticipantsEvent, HangEventParticipantsState> {
  final HangEventRepository _hangEventRepository;
  final UserRepository _userRepository;
  final UserInvitesRepository _userInvitesRepository;
  final HangEvent curEvent;
  // constructor
  HangEventParticipantsBloc({required this.curEvent})
      : _hangEventRepository = HangEventRepository(),
        _userRepository = UserRepository(),
        _userInvitesRepository = UserInvitesRepository(),
        super(HangEventParticipantsLoading());

  @override
  Stream<HangEventParticipantsState> mapEventToState(
      HangEventParticipantsEvent event) async* {
    if (event is LoadHangEventParticipants) {
      yield* _mapLoadHangEventsToState();
    }
    if (event is AddPeoplePressed) {
      yield state.copyWith(addParticipantBy: AddParticipantBy.none);
    }
    if (event is SearchByEmailPressed) {
      yield state.copyWith(
          addParticipantBy: AddParticipantBy.email, searchByEmailValue: '');
    }
    if (event is SearchByUsernamePressed) {
      yield state.copyWith(
        addParticipantBy: AddParticipantBy.username,
        searchByUsernameValue: '',
      );
    }
    if (event is SearchByUsernameChanged) {
      yield state.copyWith(searchByUsernameValue: event.usernameValue);
    }
    if (event is SearchByEmailChanged) {
      yield state.copyWith(searchByEmailValue: event.emailValue);
    }
    if (event is SearchByUsernameSubmitted) {
      yield SearchParticipantLoading(state);
      yield* _mapSearchParticipantsState();
    }
    if (event is SearchByEmailSubmitted) {
      yield SearchParticipantLoading(state);
      yield* _mapSearchParticipantsState();
    }
    if (event is ClearSearchFields) {
      yield state.copyWith(
          searchByEmailValue: '',
          searchByUsernameValue: '',
          addParticipantBy: AddParticipantBy.none);
    }
    if (event is SendInviteInitiated) {
      yield SendInviteLoading(state);
      yield* _mapSendInviteState(event.invitedUser);
    }
  }

  Stream<HangEventParticipantsState> _mapLoadHangEventsToState() async* {
    List<UserInvite> allUserInvites =
        await _hangEventRepository.getUserInvitesForEvent(curEvent.id);

    List<UserInvite> attendingUsers = allUserInvites
        .where((element) => element.status == InviteStatus.accepted)
        .toList();

    List<UserInvite> invitedUsers = allUserInvites
        .where((element) => element.status == InviteStatus.pending)
        .toList();

    List<UserInvite> rejectedUsers = allUserInvites
        .where((element) => element.status == InviteStatus.rejected)
        .toList();
    yield state.copyWith(
        attendingUsers: attendingUsers,
        invitedUsers: invitedUsers,
        rejectedUsers: rejectedUsers);
  }

  Stream<HangEventParticipantsState> _mapSearchParticipantsState() async* {
    try {
      HangUser? retValUser;
      if (state.addParticipantBy == AddParticipantBy.username) {
        retValUser = await _userRepository
            .getUserByUserName(state.searchByUsernameValue);
      }
      if (state.addParticipantBy == AddParticipantBy.email) {
        retValUser =
            await _userRepository.getUserByEmail(state.searchByEmailValue);
      }
      if (retValUser == null) {
        yield SearchParticipantError(state,
            errorMessage: "Failed to find user.");
      } else {
        yield SearchParticipantRetrieved(state, foundUser: retValUser);
      }
    } catch (e) {
      yield SearchParticipantError(state,
          errorMessage: "Failed to find user. ${e.toString()}");
    }
  }

  Stream<HangEventParticipantsState> _mapSendInviteState(
      HangUser invitedUser) async* {
    try {
      // await _userInvitesRepository.addUserEventInvite(
      //     curEvent, UserInvite.fromInvitedEventUser(invitedUser));
      yield SendInviteSuccess(state);
    } catch (e) {
      yield SendInviteError(state,
          errorMessage: "Failed to send invite to user. ${e.toString()}");
    }
  }
}
