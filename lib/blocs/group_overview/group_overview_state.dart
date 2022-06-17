part of 'group_overview_bloc.dart';

@immutable
abstract class GroupOverviewState extends Equatable {
  const GroupOverviewState();

  @override
  List<Object> get props => [];
}

class GroupsLoading extends GroupOverviewState {}

class GroupsRetrieved extends GroupOverviewState {
  final List<Group> groupsForUser;

  GroupsRetrieved({this.groupsForUser = const <Group>[]});

  @override
  List<Object> get props => [groupsForUser];
}
