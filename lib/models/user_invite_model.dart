import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/invite.dart';
import 'hang_user_preview_model.dart';

class UserInvite extends Invite {
  final HangUserPreview user;

  const UserInvite({required this.user, required status, required type, title})
      : super(status: status, type: type, title: title);

  static UserInvite fromInvitedEventUser(HangUser user) {
    return UserInvite(
        user: HangUserPreview.fromUser(user),
        status: InviteStatus.pending,
        type: InviteType.event);
  }

  static UserInvite fromInvitedGroupUser(HangUser user) {
    return UserInvite(
        user: HangUserPreview.fromUser(user),
        status: InviteStatus.pending,
        type: InviteType.group);
  }

  static UserInvite fromInvitedEventUserPreview(HangUserPreview userPreview) {
    return UserInvite(
        user: userPreview,
        status: InviteStatus.pending,
        type: InviteType.event);
  }

  static UserInvite fromInvitedGroupUserPreview(HangUserPreview userPreview) {
    return UserInvite(
        user: userPreview,
        status: InviteStatus.pending,
        type: InviteType.group);
  }

  static UserInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  static UserInvite fromMap(Map<String, dynamic> map) {
    UserInvite group = UserInvite(
        user: HangUserPreview.fromMap(map["user"]),
        status: InviteStatus.values
            .firstWhere((e) => describeEnum(e) == map["status"]),
        type:
            InviteType.values.firstWhere((e) => describeEnum(e) == map["type"]),
        title: InviteTitle.values
            .firstWhere((e) => describeEnum(e) == map["title"]));
    return group;
  }

  @override
  Map<String, Object> toDocument() {
    return {
      "user": user.toDocument(),
      "status": describeEnum(status),
      "type": describeEnum(type),
      "title":
          title != null ? describeEnum(title!) : describeEnum(InviteTitle.user),
    };
  }

  @override
  List<Object?> get props => [user, status, type, title];
}
