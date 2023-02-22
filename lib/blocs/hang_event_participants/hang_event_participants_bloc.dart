import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_participants.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/group/base_group_repository.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/hang_event/base_hang_event_repository.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:letshang/repositories/user/base_user_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'hang_event_participants_event.dart';
part 'hang_event_participants_state.dart';

class HangEventParticipantsBloc
    extends Bloc<HangEventParticipantsEvent, HangEventParticipantsState> {
  final BaseHangEventRepository _hangEventRepository;
  final BaseUserRepository _userRepository;
  final BaseUserInvitesRepository _userInvitesRepository;
  final BaseGroupRepository _groupRepository;
  final HangEvent curEvent;
  // constructor
  HangEventParticipantsBloc({required this.curEvent})
      : _hangEventRepository = HangEventRepository(),
        _userRepository = UserRepository(),
        _userInvitesRepository = UserInvitesRepository(),
        _groupRepository = GroupRepository(),
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
    if (event is SearchByGroupChanged) {
      yield state.copyWith(searchByGroupValue: event.groupValue);
    }
    if (event is SearchByGroupSubmitted) {
      yield SearchGroupLoading(state);
      yield* _mapSearchGroupState();
    }
    if (event is SelectMembersInitiated) {
      yield SelectMembersState(state, allMembers: event.groupMembers);
    }
    if (event is SelectMembersSelected) {
      final selectMembersState = state as SelectMembersState;
      yield selectMembersState.toggleSelectedMember(
          state, event.selectedMember);
    }
    if (event is SelectMembersInviteInitiated) {
      yield SelectMembersInviteLoading(state as SelectMembersState);
      yield* _mapSendGroupInviteState(event.selectedMembers);
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
        if (state.allUsers.contains(retValUser.email)) {
          yield SearchParticipantError(state,
              errorMessage: "User is already part of this event");
        } else {
          yield SearchParticipantRetrieved(state, foundUser: retValUser);
        }
      }
    } catch (e) {
      yield SearchParticipantError(state, errorMessage: "Failed to find user.");
    }
  }

  Stream<HangEventParticipantsState> _mapSearchGroupState() async* {
    try {
      Group? retValGroup =
          await _groupRepository.getGroupByName(state.searchByGroupValue);
      if (retValGroup == null) {
        yield SearchGroupError(state, errorMessage: "Failed to find group.");
      } else {
        yield SearchGroupRetrieved(state, foundGroup: retValGroup);
      }
    } catch (e) {
      yield SearchGroupError(state, errorMessage: "Failed to find group.");
    }
  }

  Stream<HangEventParticipantsState> _mapSendGroupInviteState(
      Map<String, UserInvite> selectedMembers) async* {
    try {
      List<UserInvite> allUserInvites =
          selectedMembers.entries.map((e) => e.value).toList();
      await _userInvitesRepository.addUserEventInvites(
          curEvent, allUserInvites);
      yield SendInviteSuccess(state);
    } catch (e) {
      yield SelectMembersInviteError(state as SelectMembersState,
          errorMessage: "Failed to send invite to user.");
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
          errorMessage: "Failed to send invite to user.");
    }
  }
}
