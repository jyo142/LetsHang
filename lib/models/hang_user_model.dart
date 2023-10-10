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
  final String? id;
  late final String? name;
  late final String userName;
  late final String? email;
  late final String? phoneNumber;
  late final String? photoUrl;
  late final String? fcmToken;
  late final String? profilePicDownloadUrl;
  HangUser(
      {this.id,
      this.name = '',
      this.userName = '',
      this.email = '',
      this.phoneNumber = '',
      this.photoUrl = '',
      this.fcmToken = '',
      this.profilePicDownloadUrl = ''}) {}

  HangUser.fromFirebaseUser(String userName, String docId, User firebaseUser)
      : this(
            id: docId,
            userName: userName,
            name: firebaseUser.displayName,
            email: firebaseUser.email,
            phoneNumber: firebaseUser.phoneNumber,
            photoUrl: firebaseUser.photoURL);

  static HangUser fromSnapshot(DocumentSnapshot snap) {
    HangUser userPreview = HangUser(
        id: snap.getFromSnap("id"),
        name: snap.getFromSnap("name"),
        userName: snap.getFromSnap("userName")!,
        email: snap.getFromSnap("email"),
        phoneNumber: snap.getFromSnap("phoneNumber"),
        photoUrl: snap.getFromSnap("photoUrl"),
        fcmToken: snap.getFromSnap("fcmToken"),
        profilePicDownloadUrl: snap.getFromSnap("profilePicDownloadUrl"));
    return userPreview;
  }

  HangUser copyWith(
      {String? id,
      String? name,
      String? userName,
      String? email,
      String? phoneNumber,
      String? photoUrl,
      String? fcmToken,
      String? profilePicDownloadUrl}) {
    return HangUser(
      id: id ?? this.id,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      profilePicDownloadUrl:
          profilePicDownloadUrl ?? this.profilePicDownloadUrl,
    );
  }

  Map<String, Object?> toDocument() {
    final retVal = {
      "id": id,
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
        id,
        name,
        userName,
        email,
        phoneNumber,
        photoUrl,
        fcmToken,
        profilePicDownloadUrl
      ];
}
