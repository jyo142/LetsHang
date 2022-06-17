import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'hang_user_model.dart';

class HangUserPreview extends Equatable {
  final String userName;
  final String? name;

  HangUserPreview({this.userName = '', this.name = ''}) {}

  HangUserPreview.fromUser(HangUser user)
      : this.name = user.name,
        this.userName = user.userName;

  static HangUserPreview fromSnapshot(DocumentSnapshot snap) {
    HangUserPreview userPreview =
        HangUserPreview(userName: snap["userName"], name: snap["name"]);
    return userPreview;
  }

  static HangUserPreview fromMap(Map<String, dynamic> map) {
    HangUserPreview userPreview =
        HangUserPreview(userName: map["userName"], name: map["name"]);
    return userPreview;
  }

  Map<String, Object?> toDocument() {
    return {
      'userName': userName,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [userName, name];
}
