import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'hang_user_model.dart';

class HangUserPreview extends Equatable {
  final String userName;
  final String userId;
  final String? email;
  final String? name;
  final String? photoUrl;

  HangUserPreview(
      {required this.userId,
      this.userName = '',
      this.email = '',
      this.name = '',
      this.photoUrl = ''}) {}

  HangUserPreview.fromUser(HangUser user)
      : this.userId = user.id!,
        this.name = user.name,
        this.userName = user.userName,
        this.email = user.email,
        this.photoUrl = user.photoUrl;

  static HangUserPreview fromSnapshot(DocumentSnapshot snap) {
    HangUserPreview userPreview = HangUserPreview(
        userId: snap["userId"],
        userName: snap["userName"],
        email: snap["email"],
        name: snap["name"],
        photoUrl: snap["photoUrl"]);
    return userPreview;
  }

  static HangUserPreview fromMap(Map<String, dynamic> map) {
    HangUserPreview userPreview = HangUserPreview(
        userId: map["userId"],
        userName: map["userName"],
        email: map["email"],
        name: map["name"],
        photoUrl: map["photoUrl"]);
    return userPreview;
  }

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'name': name,
      'photoUrl': photoUrl
    };
  }

  @override
  List<Object?> get props => [userId, userName, email, name, photoUrl];
}
