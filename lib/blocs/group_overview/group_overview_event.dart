part of 'group_overview_bloc.dart';

@immutable
abstract class GroupOverviewEvent extends Equatable {
  const GroupOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadGroups extends GroupOverviewEvent {}

class UpdateGroups extends GroupOverviewEvent {
  final List<Group> groups;

  const UpdateGroups(this.groups);

  @override
  List<Object> get props => [groups];
}
