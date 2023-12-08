part of 'group_overview_bloc.dart';

enum GroupOverviewStateStatus {
  initial,
  groupsLoading,
  groupsRetrieved,
  individualGroupRetrieved,
  error,
}

@immutable
class GroupOverviewState extends Equatable {
  final GroupOverviewStateStatus groupOverviewStateStatus;
  final Group? individualGroup;
  final List<GroupInvite>? groupsForUser;
  final String? errorMessage;
  const GroupOverviewState(
      {required this.groupOverviewStateStatus,
      this.individualGroup,
      this.groupsForUser,
      this.errorMessage});

  GroupOverviewState copyWith({
    GroupOverviewStateStatus? groupOverviewStateStatus,
    Group? individualGroup,
    List<GroupInvite>? groupsForUser,
    String? errorMessage,
  }) {
    return GroupOverviewState(
        groupOverviewStateStatus:
            groupOverviewStateStatus ?? this.groupOverviewStateStatus,
        individualGroup: individualGroup ?? this.individualGroup,
        groupsForUser: groupsForUser ?? this.groupsForUser,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [groupOverviewStateStatus, individualGroup, groupsForUser, errorMessage];
}
