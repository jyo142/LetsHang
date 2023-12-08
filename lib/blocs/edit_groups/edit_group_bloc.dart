import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/group_preview.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/discussions/base_discussions_repository.dart';
import 'package:letshang/repositories/discussions/discussions_repository.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'edit_group_state.dart';
part 'edit_group_event.dart';

class EditGroupBloc extends Bloc<EditGroupEvent, EditGroupState> {
  final GroupRepository _groupRepository;
  final HangUserPreview creatingUser;
  final BaseUserInvitesRepository _invitesRepository;
  final BaseDiscussionsRepository _discussionsRepository;
  final Group? existingGroup;
  // constructor
  EditGroupBloc({required this.creatingUser, this.existingGroup})
      : _groupRepository = GroupRepository(),
        _invitesRepository = UserInvitesRepository(),
        _discussionsRepository = DiscussionsRepository(),
        super(EditGroupState(
            groupName: existingGroup?.groupName ?? '',
            groupOwner: existingGroup?.groupOwner ?? creatingUser,
            groupUserInvitees: existingGroup?.userInvites != null
                ? {
                    for (var member in existingGroup!.userInvites)
                      member.user.userName: member
                  }
                : null)) {
    on<GroupNameChanged>((event, emit) async {
      emit(state.copyWith(groupName: event.groupName));
    });
    on<DeleteGroupMemberInitialized>((event, emit) async {
      emit(state.deleteGroupMember(event.groupMemberUserName));
    });
    on<SaveGroupInitiated>((event, emit) async {
      emit(SaveGroupLoading(state));
      emit(await _mapGroupSavedState(event));
    });
  }

  Future<EditGroupState> _mapGroupSavedState(SaveGroupInitiated event) async {
    try {
      Group savingGroup = Group(
          id: existingGroup?.id ?? "",
          groupName: state.groupName,
          userInvites: event.allInvitedMembers,
          groupOwner: creatingUser);

      Group retvalGroup;
      if (existingGroup != null) {
        // this event is being edited if an id is present
        retvalGroup = await _groupRepository.editGroup(savingGroup);
        retvalGroup =
            retvalGroup.copyWith(userInvites: List.of(event.allInvitedMembers));
        await _invitesRepository.editUserGroupInvites(retvalGroup);
      } else {
        retvalGroup = await _groupRepository.addGroup(savingGroup);
        await _invitesRepository.addUserGroupInvites(
            retvalGroup, event.allInvitedMembers);
        await _discussionsRepository.addGroupDiscussion(
            GroupPreview.fromGroup(retvalGroup),
            event.allInvitedMembers.map((m) => m.user).toList());
      }
      return SavedGroupSuccessfully(state);
    } catch (_) {
      return SaveGroupError(state, errorMessage: 'Unable to save group.');
    }
  }
}
