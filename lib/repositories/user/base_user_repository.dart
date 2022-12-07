import 'package:letshang/models/hang_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseUserRepository {
  Future<HangUser?> getUserByUserName(String userName);
  Future<HangUser?> getUserByEmail(String email);
  Future<void> addUser(HangUser user);
  Future<void> updateUser(HangUser user);
  Future<void> addFirebaseUser(String email, User firebaseUser);
  Future<void> updateFCMToken(String email, String fcmToken);
}
