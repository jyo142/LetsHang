import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_participants.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
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

part 'participants_event.dart';
part 'participants_state.dart';

class ParticipantsBloc extends Bloc<ParticipantsEvent, ParticipantsState> {
  final BaseHangEventRepository _hangEventRepository;
  final BaseUserRepository _userRepository;
  final BaseUserInvitesRepository _userInvitesRepository;
  final BaseGroupRepository _groupRepository;
  final HangEvent? curEvent;
  final Group? curGroup;
  // constructor
  ParticipantsBloc({this.curEvent, this.curGroup})
      : _hangEventRepository = HangEventRepository(),
        _userRepository = UserRepository(),
        _userInvitesRepository = UserInvitesRepository(),
        _groupRepository = GroupRepository(),
        super(HangEventParticipantsLoading());

  @override
  Stream<ParticipantsState> mapEventToState(ParticipantsEvent event) async* {
    if (event is LoadHangEventParticipants) {
      yield* _mapLoadEventInvitesToState();
    }
    if (event is LoadGroupParticipants) {
      if (curGroup != null) {
        yield* _mapLoadGroupInvitesToState();
      }
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
    if (event is SendRemoveInviteInitiated) {
      yield SendInviteLoading(state);
      yield* _mapSendRemoveInviteState(event.toRemoveUser);
    }
    if (event is AddInviteeInitiated) {
      ParticipantsState newState = state.addInvitee(
          HangUserPreview.fromUser(event.invitedUser), event.inviteTitle);
      yield newState.copyWith(
          searchByEmailValue: '',
          searchByUsernameValue: '',
          addParticipantBy: AddParticipantBy.none);
    }
    if (event is RemoveInviteeInitiated) {
      ParticipantsState newState =
          state.removeInvitee(event.toRemoveUserPreview);
      yield newState;
    }
    if (event is SendAllInviteesInitiated) {
      yield SendAllInvitesLoading(state);
      yield* _mapSendAllInviteesState(state.invitedUsers);
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
    if (event is PromoteInviteeInitiated) {
      ParticipantsState newState =
          state.promoteInvitee(event.toPromoteUserPreview);
      yield newState;
    }
    if (event is SendPromoteInviteeInitiated) {
      yield SendInviteLoading(state);
      yield* _mapSendPromoteInviteState(event.toPromoteUserPreview);
    }
  }

  Stream<ParticipantsState> _mapLoadGroupInvitesToState() async* {
    List<UserInvite> allUserInvites =
        await _groupRepository.getUserInvitesForGroup(curGroup!.id);

    List<UserInvite> attendingUsers = allUserInvites
        .where((element) =>
            element.status == InviteStatus.accepted ||
            element.status == InviteStatus.owner)
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

  Stream<ParticipantsState> _mapLoadEventInvitesToState() async* {
    List<UserInvite> allUserInvites =
        await _hangEventRepository.getUserInvitesForEvent(curEvent!.id);

    List<UserInvite> attendingUsers = allUserInvites
        .where((element) =>
            element.status == InviteStatus.accepted ||
            element.status == InviteStatus.owner)
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

  Stream<ParticipantsState> _mapSearchParticipantsState() async* {
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

  Stream<ParticipantsState> _mapSearchGroupState() async* {
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

  Stream<ParticipantsState> _mapSendGroupInviteState(
      Map<String, UserInvite> selectedMembers) async* {
    try {
      List<UserInvite> allUserInvites =
          selectedMembers.entries.map((e) => e.value).toList();
      await _userInvitesRepository.addUserEventInvites(
          curEvent!, allUserInvites);
      yield SendInviteSuccess(state);
    } catch (e) {
      yield SelectMembersInviteError(state as SelectMembersState,
          errorMessage: "Failed to send invite to user.");
    }
  }

  Stream<ParticipantsState> _mapSendAllInviteesState(
      List<UserInvite> allInvitedUsers) async* {
    try {
      await _userInvitesRepository.addUserEventInvites(
          curEvent!, allInvitedUsers);
      HangEvent savingEvent =
          curEvent!.copyWith(currentStage: HangEventStage.complete);
      await _hangEventRepository.editHangEvent(savingEvent);
      yield SendAllInvitesSuccess(state);
    } catch (e) {
      yield SendAllInvitesError(state,
          errorMessage: "Failed to send invites to users.");
    }
  }

  Stream<ParticipantsState> _mapSendInviteState(HangUser invitedUser) async* {
    try {
      if (curEvent != null) {
        await _userInvitesRepository.addUserEventInvite(
            curEvent!, UserInvite.fromInvitedEventUser(invitedUser));
        yield SendInviteSuccess(state);
      }
      if (curGroup != null) {
        await _userInvitesRepository.addUserGroupInvite(
            curGroup!, UserInvite.fromInvitedGroupUser(invitedUser));
        yield SendInviteSuccess(state);
      }
    } catch (e) {
      yield SendInviteError(state,
          errorMessage: "Failed to send invite to user.");
    }
  }

  Stream<ParticipantsState> _mapSendRemoveInviteState(
      HangUserPreview toRemoveUser) async* {
    try {
      if (curEvent != null) {
        await _userInvitesRepository.removeUserEventInvite(
            curEvent!, UserInvite.fromInvitedEventUserPreview(toRemoveUser));
        yield SendInviteSuccess(state);
      }
      if (curGroup != null) {
        await _userInvitesRepository.removeUserGroupInvite(
            curGroup!, UserInvite.fromInvitedGroupUserPreview(toRemoveUser));
        yield SendInviteSuccess(state);
      }
    } catch (e) {
      yield SendInviteError(state,
          errorMessage: "Failed to send invite to user.");
    }
  }

  Stream<ParticipantsState> _mapSendPromoteInviteState(
      HangUserPreview toRemoveUser) async* {
    try {
      if (curEvent != null) {
        await _userInvitesRepository.promoteUserEventInvite(
            curEvent!, UserInvite.fromInvitedEventUserPreview(toRemoveUser));
        yield SendInviteSuccess(state);
      }
      if (curGroup != null) {
        await _userInvitesRepository.promoteUserGroupInvite(
            curGroup!, UserInvite.fromInvitedGroupUserPreview(toRemoveUser));
        yield SendInviteSuccess(state);
      }
    } catch (e) {
      yield SendInviteError(state, errorMessage: "Failed to promote user.");
    }
  }
}
