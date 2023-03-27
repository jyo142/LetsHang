import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/utils/firebase_utils.dart';

enum SearchUserBy { email, username, group }

extension ParseToString on SearchUserBy {
  String toShortString() {
    return toString().split('.').last;
  }
}

class HangUser extends Equatable {
  late final String? name;
  late String userName;
  late final String? email;
  late final String? phoneNumber;
  late final String? photoUrl;
  late String? fcmToken;
  late String? profilePicDownloadUrl;
  HangUser(
      {this.name = '',
      this.userName = '',
      this.email = '',
      this.phoneNumber = '',
      this.photoUrl = '',
      this.fcmToken = '',
      this.profilePicDownloadUrl = ''}) {}

  HangUser.fromFirebaseUser(String userName, User firebaseUser)
      : this(
            userName: userName,
            name: firebaseUser.displayName,
            email: firebaseUser.email,
            phoneNumber: firebaseUser.phoneNumber,
            photoUrl: firebaseUser.photoURL);

  static HangUser fromSnapshot(DocumentSnapshot snap) {
    HangUser userPreview = HangUser(
        name: snap.getFromSnap("name"),
        userName: snap.getFromSnap("userName")!,
        email: snap.getFromSnap("email"),
        phoneNumber: snap.getFromSnap("phoneNumber"),
        photoUrl: snap.getFromSnap("photoUrl"),
        fcmToken: snap.getFromSnap("fcmToken"),
        profilePicDownloadUrl: snap.getFromSnap("profilePicDownloadUrl"));
    return userPreview;
  }

  Map<String, Object> toDocument() {
    final retVal = {
      'userName': userName,
      'name': name ?? "",
      'email': email ?? "",
      'phoneNumber': phoneNumber ?? "",
      'photoUrl': photoUrl ?? "",
      'fcmToken': fcmToken ?? "",
      'profilePicDownloadUrl': profilePicDownloadUrl ?? ""
    };
    return retVal;
  }

  @override
  List<Object?> get props => [
        name,
        userName,
        email,
        phoneNumber,
        photoUrl,
        fcmToken,
        profilePicDownloadUrl
      ];
}
