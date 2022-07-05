import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SearchUserBy { email, username, group }

extension ParseToString on SearchUserBy {
  String toShortString() {
    return toString().split('.').last;
  }
}

class HangUser extends Equatable {
  late final String? name;
  late final String userName;
  late final String? email;
  late final String? phoneNumber;
  late final String? photoUrl;

  HangUser(
      {this.name = '',
      this.userName = '',
      this.email = '',
      this.phoneNumber = '',
      this.photoUrl = ''}) {}

  HangUser.fromFirebaseUser(this.userName, User firebaseUser) {
    name = firebaseUser.displayName;
    email = firebaseUser.email;
    phoneNumber = firebaseUser.phoneNumber;
    photoUrl = firebaseUser.photoURL;
  }

  static HangUser fromSnapshot(DocumentSnapshot snap) {
    HangUser userPreview = HangUser(
        name: snap["name"],
        userName: snap["userName"],
        email: snap["email"],
        phoneNumber: snap["phoneNumber"],
        photoUrl: snap["photoUrl"]);
    return userPreview;
  }

  Map<String, Object> toDocument() {
    final retVal = {
      'userName': userName,
      'name': name ?? "",
      'email': email ?? "",
      'phoneNumber': phoneNumber ?? "",
      'photoUrl': photoUrl ?? ""
    };
    return retVal;
  }

  @override
  List<Object?> get props => [name, userName, email, phoneNumber, photoUrl];
}
