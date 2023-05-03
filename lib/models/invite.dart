import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum InviteStatus { incomplete, pending, owner, accepted, rejected }

enum InviteType { group, event }

enum InviteTitle { organizer, admin, user }

class Invite extends Equatable {
  final InviteStatus status;
  final InviteType type;
  final InviteTitle? title;

  const Invite({required this.status, required this.type, this.title});

  static Invite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  static Invite fromMap(Map<String, dynamic> map) {
    Invite group = Invite(
        status: InviteStatus.values
            .firstWhere((e) => describeEnum(e) == map["status"]),
        type:
            InviteType.values.firstWhere((e) => describeEnum(e) == map["type"]),
        title: map.containsKey("title")
            ? InviteTitle.values
                .firstWhere((e) => describeEnum(e) == map["title"])
            : null);

    return group;
  }

  Map<String, Object> toDocument() {
    return {
      "status": status.toString(),
      "type": type.toString(),
      "title": title.toString()
    };
  }

  @override
  List<Object?> get props => [status, type, title];
}
