part of 'edit_group_bloc.dart';

@immutable
class EditGroupState extends Equatable {
  final String groupName;
  final HangUserPreview groupOwner;
  final String findGroupMember;
  late final Map<String, HangUserPreview> groupMembers;
  final SearchUserBy searchGroupMemberBy;

  EditGroupState(
      {this.groupName = '',
      required this.groupOwner,
      this.findGroupMember = '',
      Map<String, HangUserPreview>? groupMembers,
      this.searchGroupMemberBy = SearchUserBy.username})
      : this.groupMembers = groupMembers ?? {groupOwner.userName: groupOwner};

  EditGroupState.fromState(EditGroupState state)
      : this(
            groupName: state.groupName,
            groupOwner: state.groupOwner,
            findGroupMember: state.findGroupMember,
            groupMembers: state.groupMembers,
            searchGroupMemberBy: state.searchGroupMemberBy);

  EditGroupState copyWith(
      {String? groupName,
      HangUserPreview? groupOwner,
      String? findGroupMember,
      Map<String, HangUserPreview>? groupMembers,
      SearchUserBy? searchGroupMemberBy}) {
    return EditGroupState(
        groupName: groupName ?? this.groupName,
        groupOwner: groupOwner ?? this.groupOwner,
        findGroupMember: findGroupMember ?? this.findGroupMember,
        groupMembers: groupMembers ?? this.groupMembers,
        searchGroupMemberBy: searchGroupMemberBy ?? this.searchGroupMemberBy);
  }

  EditGroupState addGroupMember(HangUserPreview newGroupMember) {
    final newGroupMembers = Map.of(groupMembers);
    newGroupMembers.putIfAbsent(newGroupMember.userName, () => newGroupMember);
    return EditGroupState(
        groupName: groupName,
        groupOwner: groupOwner,
        findGroupMember: findGroupMember,
        groupMembers: newGroupMembers);
  }

  EditGroupState deleteGroupMember(String groupMemberUserName) {
    final newGroupMembers = Map.of(groupMembers);
    newGroupMembers.remove(groupMemberUserName);
    return EditGroupState(
        groupName: groupName,
        groupOwner: groupOwner,
        findGroupMember: findGroupMember,
        groupMembers: newGroupMembers);
  }

  @override
  List<Object?> get props => [
        groupMembers,
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
