import 'package:letshang/models/hang_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseUserRepository {
  Future<HangUser?> getUserByUserName(String userName);
  Future<HangUser?> getUserByEmail(String userName);
  Future<void> addUser(String userName, User firebaseUser);
}
