import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/repositories/group/base_group_repository.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'group_overview_event.dart';
part 'group_overview_state.dart';

class GroupOverviewBloc extends Bloc<GroupOverviewEvent, GroupOverviewState> {
  final BaseUserInvitesRepository _userInvitesRepository;
  final BaseGroupRepository _groupRepository;

  // constructor
  GroupOverviewBloc()
      : _userInvitesRepository = UserInvitesRepository(),
        _groupRepository = GroupRepository(),
        super(const GroupOverviewState(
            groupOverviewStateStatus: GroupOverviewStateStatus.initial)) {
    on<LoadGroupInvites>((event, emit) async {
      emit(state.copyWith(
          groupOverviewStateStatus: GroupOverviewStateStatus.groupsLoading));
      List<GroupInvite> groups =
          await _userInvitesRepository.getUserGroupInvites(event.userId);
      emit(state.copyWith(
          groupOverviewStateStatus: GroupOverviewStateStatus.groupsRetrieved,
          groupsForUser: groups));
    });
    on<LoadIndividualGroup>((event, emit) async {
      emit(state.copyWith(
          groupOverviewStateStatus: GroupOverviewStateStatus.groupsLoading));
      Group? foundGroup = await _groupRepository.getGroupById(event.groupId);
      if (foundGroup != null) {
        emit(state.copyWith(
            groupOverviewStateStatus:
                GroupOverviewStateStatus.individualGroupRetrieved,
            individualGroup: foundGroup));
      } else {
        emit(state.copyWith(errorMessage: "Unable to find group"));
      }
    });
  }
}
