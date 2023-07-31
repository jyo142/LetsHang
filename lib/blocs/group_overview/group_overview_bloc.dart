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
        super(GroupsLoading());

  @override
  Stream<GroupOverviewState> mapEventToState(GroupOverviewEvent event) async* {
    if (event is LoadGroupInvites) {
      List<GroupInvite> groups =
          await _userInvitesRepository.getUserGroupInvites(event.email);
      yield GroupsRetrieved(groupsForUser: groups);
    }
    if (event is LoadIndividualGroup) {
      yield IndividualGroupLoading();
      Group? foundGroup = await _groupRepository.getGroupById(event.groupId);
      if (foundGroup != null) {
        yield IndividualGroupRetrieved(group: foundGroup);
      } else {
        yield IndividualGroupRetrievedError(
            errorMessage: "Unable to find group");
      }
    }
  }
}
