part of 'edit_group_bloc.dart';

abstract class EditGroupEvent extends Equatable {
  const EditGroupEvent();

  @override
  List<Object> get props => [];
}

class FindGroupMemberChanged extends EditGroupEvent {
  const FindGroupMemberChanged({required this.findGroupMember});

  final String findGroupMember;

  @override
  List<Object> get props => [findGroupMember];
}

class FindGroupMemberInitiated extends EditGroupEvent {}

class GroupNameChanged extends EditGroupEvent {
  const GroupNameChanged({required this.groupName});

  final String groupName;

  @override
  List<Object> get props => [groupName];
}

class AddGroupMemberInitialized extends EditGroupEvent {
  const AddGroupMemberInitialized({required this.groupMember});

  final HangUser groupMember;

  @override
  List<Object> get props => [groupMember];
}

class DeleteGroupMemberInitialized extends EditGroupEvent {
  const DeleteGroupMemberInitialized({required this.groupMemberUserName});

  final String groupMemberUserName;

  @override
  List<Object> get props => [groupMemberUserName];
}

class SaveGroupInitiated extends EditGroupEvent {
  final List<UserInvite> allInvitedMembers;

  const SaveGroupInitiated({required this.allInvitedMembers});
  @override
  List<Object> get props => [allInvitedMembers];
}

class SearchByGroupMemberChanged extends EditGroupEvent {
  const SearchByGroupMemberChanged(this.searchGroupMemberBy);

  final SearchUserBy searchGroupMemberBy;
  @override
  List<Object> get props => [searchGroupMemberBy];
}
