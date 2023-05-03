import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/user_invite_model.dart';

abstract class BaseGroupRepository {
  Future<Group?> getGroupByName(String groupName);
  Future<List<Group>> getGroupsForUser(String userName);
  // this method gets all of the user invites for a grouop
  Future<List<UserInvite>> getUserInvitesForGroup(String groupId);
  Future<Group> addGroup(Group newGroup);
  Future<Group> editGroup(Group editGroup);
}
