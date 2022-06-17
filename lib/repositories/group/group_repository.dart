import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/repositories/group/base_group_repository.dart';

class GroupRepository extends BaseGroupRepository {
  final FirebaseFirestore _firebaseFirestore;

  GroupRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Group>> getGroupsForUser(String userName) async {
    QuerySnapshot querySnapshots = await _firebaseFirestore
        .collection('groups')
        .where('memberIds', arrayContains: userName)
        .get();

    return querySnapshots.docs.map((doc) => Group.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> addGroup(Group newGroup) {
    return _firebaseFirestore.collection('groups').add(newGroup.toDocument());
  }

  @override
  Future<void> editGroup(Group editGroup) {
    return _firebaseFirestore
        .collection('groups')
        .doc(editGroup.id)
        .set(editGroup.toDocument());
  }
}
