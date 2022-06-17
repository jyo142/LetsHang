import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'group_overview_event.dart';
part 'group_overview_state.dart';

class GroupOverviewBloc extends Bloc<GroupOverviewEvent, GroupOverviewState> {
  final GroupRepository _groupRepository;
  final String userName;
  // constructor
  GroupOverviewBloc(
      {required GroupRepository groupRepository, required this.userName})
      : _groupRepository = groupRepository,
        super(GroupsLoading());

  @override
  Stream<GroupOverviewState> mapEventToState(GroupOverviewEvent event) async* {
    if (event is LoadGroups) {
      final groups = await _groupRepository.getGroupsForUser(userName);
      yield GroupsRetrieved(groupsForUser: groups);
    }
  }
}
