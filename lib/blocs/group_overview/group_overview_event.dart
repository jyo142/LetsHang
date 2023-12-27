part of 'group_overview_bloc.dart';

@immutable
abstract class GroupOverviewEvent extends Equatable {
  const GroupOverviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupInvites extends GroupOverviewEvent {
  final String userId;

  const LoadGroupInvites({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadIndividualGroup extends GroupOverviewEvent {
  final String groupId;
  final bool? retrieveAcceptedInvites;
  const LoadIndividualGroup(
      {required this.groupId, this.retrieveAcceptedInvites});

  @override
  List<Object?> get props => [groupId, retrieveAcceptedInvites];
}

class UpdateGroups extends GroupOverviewEvent {
  final List<Group> groups;

  const UpdateGroups(this.groups);

  @override
  List<Object> get props => [groups];
}
