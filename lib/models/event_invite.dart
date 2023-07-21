import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';

class HangEventInvite extends Invite {
  final HangEvent event;
  final DateTime? eventStartDateTime;
  final DateTime? eventEndDateTime;
  const HangEventInvite(
      {required this.event,
      required status,
      required type,
      title,
      this.eventStartDateTime,
      this.eventEndDateTime})
      : super(status: status, type: type, title: title);

  static HangEventInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  HangEventInvite.withUserInvite(HangEvent event, UserInvite userInvite)
      : this(
          event: event,
          status: userInvite.status,
          type: userInvite.type,
          title: userInvite.title,
        );

  HangEventInvite copyWith(
      {HangEvent? event,
      InviteStatus? status,
      InviteType? type,
      InviteTitle? title,
      DateTime? eventStartDateTime,
      DateTime? eventEndDateTime}) {
    return HangEventInvite(
        event: event ?? this.event,
        status: status ?? this.status,
        type: type ?? this.type,
        title: title ?? this.title,
        eventStartDateTime: eventStartDateTime ?? this.eventStartDateTime,
        eventEndDateTime: eventEndDateTime ?? this.eventEndDateTime);
  }

  static HangEventInvite fromMap(Map<String, dynamic> map) {
    HangEventInvite group = HangEventInvite(
        event: HangEvent.fromMap(map["event"]),
        status: InviteStatus.values
            .firstWhere((e) => describeEnum(e) == map["status"]),
        type:
            InviteType.values.firstWhere((e) => describeEnum(e) == map["type"]),
        title: InviteTitle.values
            .firstWhere((e) => describeEnum(e) == map["title"]),
        eventStartDateTime: map["eventStartDateTime"] != null
            ? (map["eventStartDateTime"]).toDate()
            : null,
        eventEndDateTime: map["eventEndDateTime"] != null
            ? (map["eventEndDateTime"]).toDate()
            : null);

    return group;
  }

  @override
  Map<String, Object?> toDocument() {
    return {
      "event": event.toDocument(),
      "status": describeEnum(status),
      "type": describeEnum(type),
      "title":
          title != null ? describeEnum(title!) : describeEnum(InviteTitle.user),
      "eventStartDateTime": eventStartDateTime != null
          ? Timestamp.fromDate(eventStartDateTime!)
          : null,
      "eventEndDateTime": eventEndDateTime != null
          ? Timestamp.fromDate(eventEndDateTime!)
          : null
    };
  }

  @override
  List<Object?> get props =>
      [event, status, type, title, eventStartDateTime, eventEndDateTime];
}
