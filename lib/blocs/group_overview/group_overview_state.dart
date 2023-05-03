part of 'group_overview_bloc.dart';

@immutable
abstract class GroupOverviewState extends Equatable {
  const GroupOverviewState();

  @override
  List<Object> get props => [];
}

class GroupsLoading extends GroupOverviewState {}

class GroupsRetrieved extends GroupOverviewState {
  final List<GroupInvite> groupsForUser;

  const GroupsRetrieved({this.groupsForUser = const <GroupInvite>[]});

  @override
  List<Object> get props => [groupsForUser];
}
