part of 'group_overview_bloc.dart';

@immutable
abstract class GroupOverviewEvent extends Equatable {
  const GroupOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupInvites extends GroupOverviewEvent {
  final String userId;

  const LoadGroupInvites({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadIndividualGroup extends GroupOverviewEvent {
  final String groupId;

  const LoadIndividualGroup({required this.groupId});

  @override
  List<Object> get props => [groupId];
}

class UpdateGroups extends GroupOverviewEvent {
  final List<Group> groups;

  const UpdateGroups(this.groups);

  @override
  List<Object> get props => [groups];
}
