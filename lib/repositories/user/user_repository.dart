import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/repositories/user/base_user_repository.dart';

class UserRepository extends BaseUserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<HangUser?> getUserByUserName(String userName) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('users')
        .where('userName', isEqualTo: userName)
        .get();
    if (querySnapshot.size > 0) {
      return HangUser.fromSnapshot(querySnapshot.docs.single);
    }
    return null;
  }

  @override
  Future<HangUser?> getUserByEmail(String email) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.size > 0) {
      return HangUser.fromSnapshot(querySnapshot.docs.single);
    }
    return null;
  }

  @override
  Future<void> addUser(HangUser user) {
    HangUser newUserWithId = user.copyWith(
        id: FirebaseFirestore.instance.collection('users').doc().id);
    return _firebaseFirestore
        .collection('users')
        .doc(newUserWithId.id)
        .set(newUserWithId.toDocument());
  }

  @override
  Future<void> updateUser(HangUser user) {
    return _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .set(user.toDocument());
  }

  @override
  Future<void> addFirebaseUser(String email, User firebaseUser) {
    HangUser addingFirebaseUser = HangUser.fromFirebaseUser("",
        FirebaseFirestore.instance.collection('users').doc().id, firebaseUser);
    return _firebaseFirestore
        .collection('users')
        .doc(addingFirebaseUser.id)
        .set(addingFirebaseUser.toDocument());
  }

  @override
  Future<void> updateFCMToken(String email, String? fcmToken) async {
    HangUser? curUser = await getUserByEmail(email);
    if (curUser != null && curUser.fcmToken != fcmToken) {
      // only update the token if it is different
      return _firebaseFirestore
          .collection('users')
          .doc(email)
          .update({"fcmToken": fcmToken});
    }
  }
}
