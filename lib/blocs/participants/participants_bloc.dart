import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_participants.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/discussions/base_discussions_repository.dart';
import 'package:letshang/repositories/discussions/discussions_repository.dart';
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
  final BaseDiscussionsRepository _discussionsRepository;
  final BaseUserRepository _userRepository;
  final BaseUserInvitesRepository _userInvitesRepository;
  final BaseGroupRepository _groupRepository;
  final HangUserPreview curUser;
  final HangEvent? curEvent;
  final Group? curGroup;
  // constructor
  ParticipantsBloc({required this.curUser, this.curEvent, this.curGroup})
      : _hangEventRepository = HangEventRepository(),
        _discussionsRepository = DiscussionsRepository(),
        _userRepository = UserRepository(),
        _userInvitesRepository = UserInvitesRepository(),
        _groupRepository = GroupRepository(),
        super(HangEventParticipantsLoading()) {
    on<LoadHangEventParticipants>((event, emit) async {
      emit(await _mapLoadEventInvitesToState());
    });
    on<LoadGroupParticipants>((event, emit) async {
      if (curGroup != null) {
        emit(await _mapLoadGroupInvitesToState());
      }
    });
    on<AddPeoplePressed>((event, emit) {
      emit(state.copyWith(addParticipantBy: AddParticipantBy.none));
    });
    on<SearchByEmailPressed>((event, emit) {
      emit(state.copyWith(
          addParticipantBy: AddParticipantBy.email, searchByEmailValue: ''));
    });
    on<SearchByUsernamePressed>((event, emit) {
      emit(state.copyWith(
        addParticipantBy: AddParticipantBy.username,
        searchByUsernameValue: '',
      ));
    });
    on<SearchByUsernameChanged>((event, emit) {
      emit(state.copyWith(searchByUsernameValue: event.usernameValue));
    });
    on<SearchByEmailChanged>((event, emit) {
      emit(state.copyWith(searchByEmailValue: event.emailValue));
    });
    on<SearchByUsernameSubmitted>((event, emit) async {
      emit(SearchParticipantLoading(state));
      emit(await _mapSearchParticipantsState());
    });
    on<SearchByEmailSubmitted>((event, emit) async {
      emit(SearchParticipantLoading(state));
      emit(await _mapSearchParticipantsState());
    });
    on<ClearSearchFields>((event, emit) {
      emit(state.copyWith(
          searchByEmailValue: '',
          searchByUsernameValue: '',
          addParticipantBy: AddParticipantBy.none));
    });
    on<SendInviteInitiated>((event, emit) async {
      emit(SendInviteLoading(state));
      emit(await _mapSendInviteState(event.invitedUser));
    });
    on<SendRemoveInviteInitiated>((event, emit) async {
      emit(SendInviteLoading(state));
      emit(await _mapSendRemoveInviteState(event.toRemoveUser));
    });
    on<AddInviteeInitiated>((event, emit) {
      ParticipantsState newState = state.addInvitee(
          HangUserPreview.fromUser(event.invitedUser),
          event.inviteType,
          event.inviteTitle,
          event.inviteStatus);
      emit(newState.copyWith(
          searchByEmailValue: '',
          searchByUsernameValue: '',
          addParticipantBy: AddParticipantBy.none));
    });
    on<RemoveInviteeInitiated>((event, emit) {
      ParticipantsState newState =
          state.removeInvitee(event.toRemoveUserPreview);
      emit(newState);
    });
    on<SendAllInviteesInitiated>((event, emit) async {
      emit(SendAllInvitesLoading(state));
      emit(await _mapSendAllInviteesState(state.invitedUsers));
    });
    on<SearchByGroupChanged>((event, emit) {
      emit(state.copyWith(searchByGroupValue: event.groupValue));
    });
    on<SearchByGroupSubmitted>((event, emit) async {
      emit(SearchGroupLoading(state));
      emit(await _mapSearchGroupState());
    });
    on<SelectMembersInitiated>((event, emit) {
      emit(SelectMembersState(state, allMembers: event.groupMembers));
    });
    on<SelectMembersSelected>((event, emit) {
      final selectMembersState = state as SelectMembersState;
      emit(
          selectMembersState.toggleSelectedMember(state, event.selectedMember));
    });
    on<SelectMembersInviteInitiated>((event, emit) async {
      emit(SelectMembersInviteLoading(state as SelectMembersState));
      emit(await _mapSendGroupInviteState(event.selectedMembers));
    });
    on<PromoteInviteeInitiated>((event, emit) {
      ParticipantsState newState =
          state.promoteInvitee(event.toPromoteUserPreview);
      emit(newState);
    });
    on<SendPromoteInviteeInitiated>((event, emit) async {
      emit(SendInviteLoading(state));
      emit(await _mapSendPromoteInviteState(event.toPromoteUserPreview));
    });
  }

  Future<ParticipantsState> _mapLoadGroupInvitesToState() async {
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

    return state.copyWith(
        attendingUsers: attendingUsers,
        invitedUsers: invitedUsers,
        rejectedUsers: rejectedUsers);
  }

  Future<ParticipantsState> _mapLoadEventInvitesToState() async {
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

    return state.copyWith(
        attendingUsers: attendingUsers,
        invitedUsers: invitedUsers,
        rejectedUsers: rejectedUsers);
  }

  Future<ParticipantsState> _mapSearchParticipantsState() async {
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
        return SearchParticipantError(state,
            errorMessage: "Failed to find user.");
      } else {
        if (state.allUsers.contains(retValUser.email)) {
          return SearchParticipantError(state,
              errorMessage: "User is already part of this event");
        } else {
          bool hasEventConflict = false;
          if (curEvent != null) {
            hasEventConflict =
                await _userInvitesRepository.hasEventInviteConflict(
                    retValUser.email!,
                    curEvent!.eventStartDateTime,
                    curEvent!.eventEndDateTime);
          }
          return SearchParticipantRetrieved(state,
              foundUser: retValUser, hasEventConflict: hasEventConflict);
        }
      }
    } catch (e) {
      return SearchParticipantError(state,
          errorMessage: "Failed to find user.");
    }
  }

  Future<ParticipantsState> _mapSearchGroupState() async {
    try {
      Group? retValGroup =
          await _groupRepository.getGroupByName(state.searchByGroupValue);
      if (retValGroup == null) {
        return SearchGroupError(state, errorMessage: "Failed to find group.");
      } else {
        return SearchGroupRetrieved(state, foundGroup: retValGroup);
      }
    } catch (e) {
      return SearchGroupError(state, errorMessage: "Failed to find group.");
    }
  }

  Future<ParticipantsState> _mapSendGroupInviteState(
      Map<String, UserInvite> selectedMembers) async {
    try {
      List<UserInvite> allUserInvites =
          selectedMembers.entries.map((e) => e.value).toList();
      await _userInvitesRepository.addUserEventInvites(
          curEvent!, allUserInvites);
      return SendInviteSuccess(state);
    } catch (e) {
      return SelectMembersInviteError(state as SelectMembersState,
          errorMessage: "Failed to send invite to user.");
    }
  }

  Future<ParticipantsState> _mapSendAllInviteesState(
      List<UserInvite> allInvitedUsers) async {
    try {
      await _userInvitesRepository.addUserEventInvites(
          curEvent!, allInvitedUsers);
      HangEvent savingEvent =
          curEvent!.copyWith(currentStage: HangEventStage.complete);
      await _hangEventRepository.editHangEvent(savingEvent);
      await _discussionsRepository.addUsersToEventMainDiscussion(
          savingEvent.id, allInvitedUsers.map((e) => e.user).toList());
      return SendAllInvitesSuccess(state);
    } catch (e) {
      return SendAllInvitesError(state,
          errorMessage: "Failed to send invites to users.");
    }
  }

  Future<ParticipantsState> _mapSendInviteState(HangUser invitedUser) async {
    try {
      if (curEvent != null) {
        await _userInvitesRepository.addUserEventInvite(
            curEvent!, UserInvite.fromInvitedEventUser(invitedUser, curUser));
        await _discussionsRepository.addUserToEventMainDiscussion(
            curEvent!.id, HangUserPreview.fromUser(invitedUser));
        return SendInviteSuccess(state);
      }
      if (curGroup != null) {
        await _userInvitesRepository.addUserGroupInvite(
            curGroup!, UserInvite.fromInvitedGroupUser(invitedUser, curUser));
        await _discussionsRepository.addUserToGroupDiscussion(
            curGroup!.id, HangUserPreview.fromUser(invitedUser));
        return SendInviteSuccess(state);
      }
      return SendInviteError(state, errorMessage: "Failed to promote user.");
    } catch (e) {
      return SendInviteError(state,
          errorMessage: "Failed to send invite to user.");
    }
  }

  Future<ParticipantsState> _mapSendRemoveInviteState(
      HangUserPreview toRemoveUser) async {
    try {
      if (curEvent != null) {
        await _userInvitesRepository.removeUserEventInvite(curEvent!,
            UserInvite.fromInvitedEventUserPreview(toRemoveUser, curUser));
        return SendInviteSuccess(state);
      }
      if (curGroup != null) {
        await _userInvitesRepository.removeUserGroupInvite(curGroup!,
            UserInvite.fromInvitedGroupUserPreview(toRemoveUser, curUser));
        return SendInviteSuccess(state);
      }
      return SendInviteError(state, errorMessage: "Failed to promote user.");
    } catch (e) {
      return SendInviteError(state,
          errorMessage: "Failed to send invite to user.");
    }
  }

  Future<ParticipantsState> _mapSendPromoteInviteState(
      HangUserPreview toRemoveUser) async {
    try {
      if (curEvent != null) {
        await _userInvitesRepository.promoteUserEventInvite(curEvent!,
            UserInvite.fromInvitedEventUserPreview(toRemoveUser, curUser));
        return SendInviteSuccess(state);
      }
      if (curGroup != null) {
        await _userInvitesRepository.promoteUserGroupInvite(curGroup!,
            UserInvite.fromInvitedGroupUserPreview(toRemoveUser, curUser));
        return SendInviteSuccess(state);
      }
      return SendInviteError(state, errorMessage: "Failed to promote user.");
    } catch (e) {
      return SendInviteError(state, errorMessage: "Failed to promote user.");
    }
  }
}
