part of 'edit_group_bloc.dart';

@immutable
class EditGroupState extends Equatable {
  final String groupName;
  final HangUserPreview groupOwner;
  final String findGroupMember;
  late final Map<String, HangUserPreview> groupMembers;

  EditGroupState(
      {this.groupName = '',
      required this.groupOwner,
      this.findGroupMember = '',
      Map<String, HangUserPreview>? groupMembers})
      : this.groupMembers = groupMembers ?? {groupOwner.userName: groupOwner};

  EditGroupState copyWith(
      {String? groupName,
      HangUserPreview? groupOwner,
      String? findGroupMember,
      Map<String, HangUserPreview>? groupMembers}) {
    return EditGroupState(
        groupName: groupName ?? this.groupName,
        groupOwner: groupOwner ?? this.groupOwner,
        findGroupMember: findGroupMember ?? this.findGroupMember,
        groupMembers: groupMembers ?? this.groupMembers);
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
  List<Object?> get props =>
      [groupMembers, groupName, groupOwner, findGroupMember];
}

class FindGroupMemberLoading extends EditGroupState {
  FindGroupMemberLoading(EditGroupState state)
      : super(
            groupName: state.groupName,
            groupMembers: state.groupMembers,
            groupOwner: state.groupOwner,
            findGroupMember: state.findGroupMember) {}
}

class FindGroupMemberRetrieved extends EditGroupState {
  final HangUser? groupMember;

  FindGroupMemberRetrieved(EditGroupState state, {this.groupMember})
      : super(
            groupName: state.groupName,
            groupMembers: state.groupMembers,
            groupOwner: state.groupOwner,
            findGroupMember: state.findGroupMember) {}

  @override
  List<Object?> get props => [groupMember];
}

class FindGroupMemberError extends EditGroupState {
  final String errorMessage;

  FindGroupMemberError(EditGroupState state, {required this.errorMessage})
      : super(
            groupName: state.groupName,
            groupMembers: state.groupMembers,
            groupOwner: state.groupOwner,
            findGroupMember: state.findGroupMember) {}

  @override
  List<Object> get props => [errorMessage];
}

class GroupMemberDeleted extends EditGroupState {
  GroupMemberDeleted(EditGroupState state)
      : super(
            groupName: state.groupName,
            groupMembers: state.groupMembers,
            groupOwner: state.groupOwner,
            findGroupMember: state.findGroupMember) {}
}
