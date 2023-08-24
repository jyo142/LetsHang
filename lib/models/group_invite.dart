import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/invite.dart';

class GroupInvite extends Invite {
  final Group group;

  const GroupInvite(
      {required this.group, required status, required type, title})
      : super(status: status, type: type, title: title);

  static GroupInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  GroupInvite copyWith(
      {Group? group,
      InviteStatus? status,
      InviteType? type,
      InviteTitle? title}) {
    return GroupInvite(
        group: group ?? this.group,
        status: status ?? this.status,
        type: type ?? this.type,
        title: title ?? this.title);
  }

  static GroupInvite fromMap(Map<String, dynamic> map) {
    Invite invite = Invite.fromMap(map);

    GroupInvite group = GroupInvite(
        group: Group.fromMap(map["group"]),
        status: invite.status,
        type: invite.type,
        title: invite.title);

    return group;
  }

  @override
  Map<String, Object> toDocument() {
    return {
      "group": group.toDocument(),
      "status": describeEnum(status),
      "type": describeEnum(type),
      "title":
          title != null ? describeEnum(title!) : describeEnum(InviteTitle.user)
    };
  }

  @override
  List<Object?> get props => [group, status, type, title];
}
