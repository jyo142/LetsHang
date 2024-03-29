import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/group/base_group_repository.dart';

class GroupRepository extends BaseGroupRepository {
  final FirebaseFirestore _firebaseFirestore;

  GroupRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<Group?> getGroupById(String groupId) async {
    DocumentSnapshot docSnapshot =
        await _firebaseFirestore.collection('groups').doc(groupId).get();
    if (docSnapshot.exists) {
      return Group.fromSnapshot(docSnapshot);
    }
    return null;
  }

  @override
  Future<Group?> getGroupByName(String groupName) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('groups')
        .where('name', isEqualTo: groupName)
        .get();
    if (querySnapshot.size > 0) {
      return constructGroup(querySnapshot.docs.single);
    }
    return null;
  }

  @override
  Future<List<Group>> getGroupsForUser(String userName) async {
    QuerySnapshot querySnapshots = await _firebaseFirestore
        .collection('groups')
        .where('memberIds', arrayContains: userName)
        .get();

    return querySnapshots.docs.map((doc) => Group.fromSnapshot(doc)).toList();
  }

  Future<Group> constructGroup(QueryDocumentSnapshot docSnap) async {
    DocumentSnapshot inviteDocSnapshot = await _firebaseFirestore
        .collection('groups')
        .doc(docSnap.id)
        .collection("invites")
        .doc("userInvites")
        .get();

    List<UserInvite> invites = [];
    if (inviteDocSnapshot.exists) {
      invites = List.of(inviteDocSnapshot["userInvites"])
          .map((m) => UserInvite.fromMap(m))
          .toList();
    }
    return Group.fromSnapshot(docSnap, invites);
  }

  @override
  Future<Group> addGroup(Group newGroup) async {
    Group savingGroup = Group.withId(
        FirebaseFirestore.instance.collection('groups').doc().id, newGroup);
    await _firebaseFirestore
        .collection('groups')
        .doc(savingGroup.id)
        .set(savingGroup.toDocument());
    return savingGroup;
  }

  @override
  Future<Group> editGroup(Group editGroup) async {
    await _firebaseFirestore
        .collection('groups')
        .doc(editGroup.id)
        .set(editGroup.toDocument());
    return editGroup;
  }

  @override
  Future<List<UserInvite>> getUserInvitesForGroup(String groupId) async {
    QuerySnapshot groupUserInvitesQuerySnap = await _firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .collection('invites')
        .get();

    final allDocSnapshots =
        groupUserInvitesQuerySnap.docs.map((doc) => doc.data()).toList();

    List<UserInvite> invites = allDocSnapshots
        .map((doc) => UserInvite.fromMap(doc as Map<String, dynamic>))
        .toList();

    return invites;
  }
}
