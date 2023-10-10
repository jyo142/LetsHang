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
        super(GroupsLoading()) {
    on<LoadGroupInvites>((event, emit) async {
      List<GroupInvite> groups =
          await _userInvitesRepository.getUserGroupInvites(event.userId);
      emit(GroupsRetrieved(groupsForUser: groups));
    });
    on<LoadIndividualGroup>((event, emit) async {
      emit(IndividualGroupLoading());
      Group? foundGroup = await _groupRepository.getGroupById(event.groupId);
      if (foundGroup != null) {
        emit(IndividualGroupRetrieved(group: foundGroup));
      } else {
        emit(const IndividualGroupRetrievedError(
            errorMessage: "Unable to find group"));
      }
    });
  }
}
