import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';

class HangEventInvite extends Invite {
  final HangEvent event;

  const HangEventInvite({required this.event, required status, required type})
      : super(status: status, type: type);

  static HangEventInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  static HangEventInvite fromMap(Map<String, dynamic> map) {
    HangEventInvite group = HangEventInvite(
        event: HangEvent.fromMap(map["event"]),
        status: InviteStatus.values
            .firstWhere((e) => describeEnum(e) == map["status"]),
        type: InviteType.values
            .firstWhere((e) => describeEnum(e) == map["type"]));

    return group;
  }

  @override
  Map<String, Object> toDocument() {
    return {
      "event": event.toDocument(),
      "status": describeEnum(status),
      "type": describeEnum(type),
    };
  }

  @override
  List<Object> get props => [event, status, type];
}
