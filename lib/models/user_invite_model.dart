import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/invite.dart';
import 'hang_user_preview_model.dart';

class UserInvite extends Invite {
  final HangUserPreview user;

  const UserInvite(
      {required this.user, required status, required type, title, invitingUser})
      : super(
            status: status,
            type: type,
            title: title,
            invitingUser: invitingUser);

  static UserInvite fromInvitedEventUser(
      HangUser user, HangUserPreview invitingUser) {
    return UserInvite(
        user: HangUserPreview.fromUser(user),
        status: InviteStatus.pending,
        type: InviteType.event,
        invitingUser: invitingUser);
  }

  static UserInvite fromInvitedGroupUser(
      HangUser user, HangUserPreview invitingUser) {
    return UserInvite(
        user: HangUserPreview.fromUser(user),
        status: InviteStatus.pending,
        type: InviteType.group,
        invitingUser: invitingUser);
  }

  static UserInvite fromInvitedEventUserPreview(
      HangUserPreview userPreview, HangUserPreview invitingUser) {
    return UserInvite(
        user: userPreview,
        status: InviteStatus.pending,
        type: InviteType.event,
        invitingUser: invitingUser);
  }

  static UserInvite fromInvitedGroupUserPreview(
      HangUserPreview userPreview, HangUserPreview invitingUser) {
    return UserInvite(
        user: userPreview,
        status: InviteStatus.pending,
        type: InviteType.group,
        invitingUser: invitingUser);
  }

  static UserInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static UserInvite fromMap(Map<String, dynamic> map) {
    Invite invite = Invite.fromMap(map);
    UserInvite group = UserInvite(
        user: HangUserPreview.fromMap(map["user"]),
        title: invite.title,
        status: invite.status,
        type: invite.type,
        invitingUser: invite.invitingUser);
    return group;
  }

  UserInvite copyWith(
      {HangUserPreview? user,
      InviteStatus? status,
      InviteType? type,
      InviteTitle? title}) {
    return UserInvite(
        user: user ?? this.user,
        status: status ?? this.status,
        type: type ?? this.type,
        title: title ?? this.title);
  }

  @override
  Map<String, Object?> toDocument() {
    final inviteToDocument = super.toDocument();
    return {"user": user.toDocument(), ...inviteToDocument};
  }

  @override
  List<Object?> get props => [user, status, type, title, invitingUser];
}
