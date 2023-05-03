part of 'edit_group_bloc.dart';

@immutable
class EditGroupState extends Equatable {
  final String groupName;
  final HangUserPreview groupOwner;
  final String findGroupMember;
  late final Map<String, UserInvite> groupUserInvitees;
  final SearchUserBy searchGroupMemberBy;

  EditGroupState(
      {this.groupName = '',
      required this.groupOwner,
      this.findGroupMember = '',
      Map<String, UserInvite>? groupUserInvitees,
      this.searchGroupMemberBy = SearchUserBy.username})
      : this.groupUserInvitees = groupUserInvitees ??
            {
              groupOwner.userName: UserInvite(
                  status: InviteStatus.pending,
                  user: groupOwner,
                  type: InviteType.event)
            };

  EditGroupState.fromState(EditGroupState state)
      : this(
            groupName: state.groupName,
            groupOwner: state.groupOwner,
            findGroupMember: state.findGroupMember,
            groupUserInvitees: state.groupUserInvitees,
            searchGroupMemberBy: state.searchGroupMemberBy);

  EditGroupState copyWith(
      {String? groupName,
      HangUserPreview? groupOwner,
      String? findGroupMember,
      Map<String, UserInvite>? groupUserInvitees,
      SearchUserBy? searchGroupMemberBy}) {
    return EditGroupState(
        groupName: groupName ?? this.groupName,
        groupOwner: groupOwner ?? this.groupOwner,
        findGroupMember: findGroupMember ?? this.findGroupMember,
        groupUserInvitees: groupUserInvitees ?? this.groupUserInvitees,
        searchGroupMemberBy: searchGroupMemberBy ?? this.searchGroupMemberBy);
  }

  EditGroupState addGroupMember(HangUserPreview newGroupMember) {
    final newGroupMembers = Map.of(groupUserInvitees);
    newGroupMembers.putIfAbsent(
        newGroupMember.userName,
        () => UserInvite(
            user: newGroupMember,
            status: InviteStatus.pending,
            type: InviteType.event));
    return EditGroupState(
        groupName: groupName,
        groupOwner: groupOwner,
        findGroupMember: findGroupMember,
        groupUserInvitees: newGroupMembers);
  }

  EditGroupState deleteGroupMember(String groupMemberUserName) {
    final newGroupMembers = Map.of(groupUserInvitees);
    newGroupMembers.remove(groupMemberUserName);
    return EditGroupState(
        groupName: groupName,
        groupOwner: groupOwner,
        findGroupMember: findGroupMember,
        groupUserInvitees: newGroupMembers);
  }

  @override
  List<Object?> get props => [
        groupUserInvitees,
        groupName,
        groupOwner,
        findGroupMember,
        searchGroupMemberBy
      ];
}

class FindGroupMemberLoading extends EditGroupState {
  FindGroupMemberLoading(EditGroupState state) : super.fromState(state);
}

class FindGroupMemberRetrieved extends EditGroupState {
  final HangUser? groupMember;

  FindGroupMemberRetrieved(EditGroupState state, {this.groupMember})
      : super.fromState(state);

  @override
  List<Object?> get props => [groupMember];
}

class FindGroupMemberError extends EditGroupState {
  final String errorMessage;

  FindGroupMemberError(EditGroupState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}

class GroupMemberDeleted extends EditGroupState {
  GroupMemberDeleted(EditGroupState state) : super.fromState(state);
}

class SaveGroupLoading extends EditGroupState {
  SaveGroupLoading(EditGroupState state) : super.fromState(state);
}

class SaveGroupError extends EditGroupState {
  final String errorMessage;

  SaveGroupError(EditGroupState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}

class SavedGroupSuccessfully extends EditGroupState {
  SavedGroupSuccessfully(EditGroupState state) : super.fromState(state);
}
