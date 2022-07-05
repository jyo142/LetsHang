import 'package:letshang/models/group_model.dart';

abstract class BaseGroupRepository {
  Future<Group?> getGroupByName(String groupName);
  Future<List<Group>> getGroupsForUser(String userName);
  Future<void> addGroup(Group newGroup);
  Future<void> editGroup(Group editGroup);
}
