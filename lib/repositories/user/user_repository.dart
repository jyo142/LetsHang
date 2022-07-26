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
    DocumentSnapshot docSnapshot =
        await _firebaseFirestore.collection('users').doc(userName).get();
    if (docSnapshot.exists) {
      return HangUser.fromSnapshot(docSnapshot);
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
    return _firebaseFirestore
        .collection('users')
        .doc(user.userName)
        .set(user.toDocument());
  }

  @override
  Future<void> addFirebaseUser(String userName, User firebaseUser) {
    return _firebaseFirestore
        .collection('users')
        .doc(userName)
        .set(HangUser.fromFirebaseUser(userName, firebaseUser).toDocument());
  }

  @override
  Future<void> updateFCMToken(String userName, String? fcmToken) async {
    HangUser? curUser = await getUserByUserName(userName);
    if (curUser != null && curUser.fcmToken != fcmToken) {
      // only update the token if it is different
      return _firebaseFirestore
          .collection('users')
          .doc(userName)
          .update({"fcmToken": fcmToken});
    }
  }
}
