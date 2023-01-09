import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/invite.dart';
import 'hang_user_preview_model.dart';

class UserInvite extends Equatable {
  final HangUserPreview user;
  final InviteStatus status;
  final InviteType type;

  const UserInvite(
      {required this.user, required this.status, required this.type});

  static UserInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  static UserInvite fromMap(Map<String, dynamic> map) {
    UserInvite group = UserInvite(
        user: HangUserPreview.fromMap(map["user"]),
        status: InviteStatus.values
            .firstWhere((e) => describeEnum(e) == map["status"]),
        type: InviteType.values
            .firstWhere((e) => describeEnum(e) == map["type"]));

    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "user": user.toDocument(),
      "status": describeEnum(status),
      "type": describeEnum(type),
    };
  }

  @override
  List<Object> get props => [user, status, type];
}
