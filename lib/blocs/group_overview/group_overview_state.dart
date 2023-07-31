part of 'group_overview_bloc.dart';

@immutable
abstract class GroupOverviewState extends Equatable {
  const GroupOverviewState();

  @override
  List<Object> get props => [];
}

class GroupsLoading extends GroupOverviewState {}

class IndividualGroupLoading extends GroupOverviewState {}

class IndividualGroupRetrieved extends GroupOverviewState {
  final Group group;

  const IndividualGroupRetrieved({required this.group});

  @override
  List<Object> get props => [group];
}

class IndividualGroupRetrievedError extends GroupOverviewState {
  final String errorMessage;

  const IndividualGroupRetrievedError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class GroupsRetrieved extends GroupOverviewState {
  final List<GroupInvite> groupsForUser;

  const GroupsRetrieved({this.groupsForUser = const <GroupInvite>[]});

  @override
  List<Object> get props => [groupsForUser];
}
