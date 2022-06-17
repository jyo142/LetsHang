import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'hang_user_preview_model.dart';

class UserToGroup extends Equatable {
  final String id;
  final String groupId;
  final HangUserPreview hangUserPreview;

  const UserToGroup({
    this.id = '',
    required this.groupId,
    required this.hangUserPreview,
  });

  static UserToGroup fromSnapshot(DocumentSnapshot snap) {
    UserToGroup group = UserToGroup(
        id: snap.id,
        groupId: snap["groupId"],
        hangUserPreview: HangUserPreview.fromSnapshot(snap["groupOwner"]));
    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "groupId": groupId,
      "hangUserPreview": hangUserPreview.toDocument(),
    };
  }

  @override
  List<Object> get props => [id, groupId, hangUserPreview];
}
