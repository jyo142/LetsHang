import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'edit_group_state.dart';
part 'edit_group_event.dart';

class EditGroupBloc extends Bloc<EditGroupEvent, EditGroupState> {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final HangUserPreview creatingUser;
  final Group? existingGroup;
  // constructor
  EditGroupBloc(
      {required GroupRepository groupRepository,
      required UserRepository userRepository,
      required this.creatingUser,
      this.existingGroup})
      : _groupRepository = groupRepository,
        _userRepository = userRepository,
        super(EditGroupState(
            groupName: existingGroup?.groupName ?? '',
            groupOwner: existingGroup?.groupOwner ?? creatingUser,
            groupMembers: existingGroup?.members != null
                ? {
                    for (var member in existingGroup!.members)
                      member.userName: member
                  }
                : null));

  @override
  Stream<EditGroupState> mapEventToState(EditGroupEvent event) async* {
    // events to do with finding members related to the group
    if (event is FindGroupMemberChanged) {
      yield state.copyWith(findGroupMember: event.findGroupMember);
    }
    if (event is FindGroupMemberInitiated) {
      yield FindGroupMemberLoading(state);
      try {
        HangUser? retValUser;
        if (state.searchGroupMemberBy == SearchUserBy.username) {
          retValUser = await _userRepository.getUserByUserName(event.userValue);
        } else if (state.searchGroupMemberBy == SearchUserBy.email) {
          retValUser = await _userRepository.getUserByEmail(event.userValue);
        }
        yield FindGroupMemberRetrieved(state, groupMember: retValUser);
      } catch (e) {
        yield FindGroupMemberError(state, errorMessage: "Failed to find user");
      }
    }
    if (event is SearchByGroupMemberChanged) {
      yield state.copyWith(searchGroupMemberBy: event.searchGroupMemberBy);
    }

    // events to do with the group metadata
    if (event is GroupNameChanged) {
      yield state.copyWith(groupName: event.groupName);
    }
    if (event is AddGroupMemberInitialized) {
      yield state.addGroupMember(HangUserPreview.fromUser(event.groupMember));
    }
    if (event is DeleteGroupMemberInitialized) {
      yield state.deleteGroupMember(event.groupMemberUserName);
    }

    if (event is SaveGroupInitiated) {
      final resultGroupMembers = List.of(state.groupMembers.values);
      Group resultGroup = Group(
          id: existingGroup?.id ?? "",
          groupName: state.groupName,
          members: resultGroupMembers,
          groupOwner: creatingUser);
      if (existingGroup != null) {
        await _groupRepository.editGroup(resultGroup);
      } else {
        await _groupRepository.addGroup(resultGroup);
      }
    }
  }
}
