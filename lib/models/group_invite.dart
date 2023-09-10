import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';

class GroupInvite extends Invite {
  final Group group;

  const GroupInvite(
      {required this.group,
      required status,
      required type,
      title,
      invitingUser})
      : super(
            status: status,
            type: type,
            title: title,
            invitingUser: invitingUser);

  static GroupInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  GroupInvite copyWith(
      {Group? group,
      InviteStatus? status,
      InviteType? type,
      InviteTitle? title,
      HangUserPreview? invitingUser}) {
    return GroupInvite(
        group: group ?? this.group,
        status: status ?? this.status,
        type: type ?? this.type,
        title: title ?? this.title,
        invitingUser: invitingUser ?? this.invitingUser);
  }

  static GroupInvite fromMap(Map<String, dynamic> map) {
    Invite invite = Invite.fromMap(map);

    GroupInvite group = GroupInvite(
        group: Group.fromMap(map["group"]),
        status: invite.status,
        type: invite.type,
        title: invite.title,
        invitingUser: invite.invitingUser);

    return group;
  }

  @override
  Map<String, Object?> toDocument() {
    final inviteToDocument = super.toDocument();
    return {"group": group.toDocument(), ...inviteToDocument};
  }

  @override
  List<Object?> get props => [group, status, type, title, invitingUser];
}
