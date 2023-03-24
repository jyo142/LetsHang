import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum InviteStatus { incomplete, pending, owner, accepted, rejected }

enum InviteType { group, event }

class Invite extends Equatable {
  final InviteStatus status;
  final InviteType type;

  const Invite({required this.status, required this.type});

  static Invite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  static Invite fromMap(Map<String, dynamic> map) {
    Invite group = Invite(
        status: InviteStatus.values
            .firstWhere((e) => describeEnum(e) == map["status"]),
        type: InviteType.values
            .firstWhere((e) => describeEnum(e) == map["type"]));

    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "status": status.toString(),
      "type": type.toString(),
    };
  }

  @override
  List<Object> get props => [status, type];
}
