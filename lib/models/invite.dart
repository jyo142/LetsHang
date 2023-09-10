import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

enum InviteStatus { incomplete, pending, owner, accepted, rejected }

enum InviteType { group, event }

enum InviteTitle { organizer, admin, user }

class Invite extends Equatable {
  final InviteStatus status;
  final InviteType type;
  final InviteTitle? title;
  final HangUserPreview? invitingUser;
  const Invite(
      {required this.status,
      required this.type,
      this.title,
      this.invitingUser});

  static Invite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static Invite fromMap(Map<String, dynamic> map) {
    Invite group = Invite(
        status: map.getFromMap(
            "status",
            (key) =>
                InviteStatus.values.firstWhere((e) => describeEnum(e) == key))!,
        type: map.getFromMap(
            "type",
            (key) =>
                InviteType.values.firstWhere((e) => describeEnum(e) == key))!,
        title: map.getFromMap(
            "title",
            (key) =>
                InviteTitle.values.firstWhere((e) => describeEnum(e) == key)),
        invitingUser: map.getFromMap(
            "invitingUser", (key) => HangUserPreview.fromMap(key)));

    return group;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object> retVal = {
      "status": describeEnum(status),
      "type": describeEnum(type),
      "title":
          title != null ? describeEnum(title!) : describeEnum(InviteTitle.user),
    };
    if (invitingUser != null) {
      retVal["invitingUser"] = invitingUser!.toDocument();
    }
    return retVal;
  }

  @override
  List<Object?> get props => [status, type, title, invitingUser];
}
