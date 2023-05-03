import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';

import 'has_user_invites.dart';

class Group extends HasUserInvites {
  final String groupName;
  final HangUserPreview groupOwner;

  Group({
    required this.groupOwner,
    id,
    this.groupName = '',
    List<UserInvite>? userInvites,
  }) : super(id, userInvites);

  Group.withId(String id, Group group)
      : this(id: id, groupName: group.groupName, groupOwner: group.groupOwner);

  static Group fromSnapshot(DocumentSnapshot snap,
      [List<UserInvite>? userInvites]) {
    return fromMap(snap.data()!, userInvites);
  }

  static Group fromMap(Map<String, dynamic> map,
      [List<UserInvite>? userInvites]) {
    Group group = Group(
        id: map["id"],
        groupName: map["name"],
        groupOwner: HangUserPreview.fromMap(map["groupOwner"]),
        userInvites: userInvites ?? []);

    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "id": id,
      "name": groupName,
      "groupOwner": groupOwner.toDocument(),
    };
  }

  Group copyWith({
    String? id,
    String? groupName,
    HangUserPreview? groupOwner,
    List<UserInvite>? userInvites,
  }) {
    return Group(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      groupOwner: groupOwner ?? this.groupOwner,
      userInvites: userInvites ?? this.userInvites,
    );
  }

  @override
  List<Object> get props => [id, groupName, groupOwner, userInvites];
}
