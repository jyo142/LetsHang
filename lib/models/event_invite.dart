import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';

class HangEventInvite extends Invite {
  final HangEvent event;

  const HangEventInvite(
      {required this.event, required status, required type, title})
      : super(status: status, type: type, title: title);

  static HangEventInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  HangEventInvite copyWith(
      {HangEvent? event,
      InviteStatus? status,
      InviteType? type,
      InviteTitle? title}) {
    return HangEventInvite(
        event: event ?? this.event,
        status: status ?? this.status,
        type: type ?? this.type,
        title: title ?? this.title);
  }

  static HangEventInvite fromMap(Map<String, dynamic> map) {
    HangEventInvite group = HangEventInvite(
      event: HangEvent.fromMap(map["event"]),
      status: InviteStatus.values
          .firstWhere((e) => describeEnum(e) == map["status"]),
      type: InviteType.values.firstWhere((e) => describeEnum(e) == map["type"]),
      title:
          InviteTitle.values.firstWhere((e) => describeEnum(e) == map["title"]),
    );

    return group;
  }

  @override
  Map<String, Object> toDocument() {
    return {
      "event": event.toDocument(),
      "status": describeEnum(status),
      "type": describeEnum(type),
      "title":
          title != null ? describeEnum(title!) : describeEnum(InviteTitle.user)
    };
  }

  @override
  List<Object?> get props => [event, status, type, title];
}
