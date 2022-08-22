import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';

class Group extends Equatable {
  final String id;
  final String groupName;
  final HangUserPreview groupOwner;
  final List<UserInvite> userInvites;

  Group({
    required this.groupOwner,
    this.id = '',
    this.groupName = '',
    List<UserInvite>? userInvites,
  }) : userInvites = userInvites ?? [];

  static Group fromSnapshot(DocumentSnapshot snap,
      [List<UserInvite>? userInvites]) {
    return fromMap(snap.data()!, userInvites);
  }

  static Group fromMap(Map<String, dynamic> map,
      [List<UserInvite>? userInvites]) {
    Group group = Group(
        groupName: map["name"],
        groupOwner: HangUserPreview.fromMap(map["groupOwner"]),
        userInvites: userInvites ?? []);

    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "name": groupName,
      "groupOwner": groupOwner.toDocument(),
      "members": userInvites.map((m) => (m.toDocument())).toList(),
    };
  }

  @override
  List<Object> get props => [id, groupName, groupOwner, userInvites];
}
