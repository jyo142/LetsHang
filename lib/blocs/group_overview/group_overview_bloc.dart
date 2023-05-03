import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'group_overview_event.dart';
part 'group_overview_state.dart';

class GroupOverviewBloc extends Bloc<GroupOverviewEvent, GroupOverviewState> {
  final BaseUserInvitesRepository _userInvitesRepository;
  final String email;
  // constructor
  GroupOverviewBloc({required this.email})
      : _userInvitesRepository = UserInvitesRepository(),
        super(GroupsLoading());

  @override
  Stream<GroupOverviewState> mapEventToState(GroupOverviewEvent event) async* {
    if (event is LoadGroups) {
      List<GroupInvite> groups =
          await _userInvitesRepository.getUserGroupInvites(email);
      yield GroupsRetrieved(groupsForUser: groups);
    }
  }
}
