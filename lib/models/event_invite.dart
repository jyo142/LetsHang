import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';

class UpcomingDraftEventInvites {
  List<HangEventInvite> draftEventInvites;
  List<HangEventInvite> upcomingEventInvites;

  UpcomingDraftEventInvites(
      {required this.draftEventInvites, required this.upcomingEventInvites});
}

class HangEventInviteUtils {
  static List<HangEventInvite> sortEventInvitesByDraftUpcoming(
      List<HangEventInvite> eventInvites) {
    List<HangEventInvite> retVal = List.from(eventInvites);
    retVal.sort((a, b) {
      if (a.event.eventStartDateTime == null &&
          b.event.eventStartDateTime == null) {
        return 0;
      } else if (a.event.eventStartDateTime == null) {
        return 1;
      } else if (b.event.eventStartDateTime == null) {
        return -1;
      } else {
        return b.event.eventStartDateTime!
            .compareTo(a.event.eventStartDateTime!);
      }
    });
    return retVal;
  }
}

class HangEventInvite extends Invite {
  final HangEvent event;
  final DateTime? eventStartDateTime;
  final DateTime? eventEndDateTime;
  const HangEventInvite(
      {required this.event,
      required status,
      required type,
      title,
      invitingUser,
      this.eventStartDateTime,
      this.eventEndDateTime})
      : super(
            status: status,
            type: type,
            title: title,
            invitingUser: invitingUser);

  static HangEventInvite fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  HangEventInvite.withEventData(HangEvent event, HangEventInvite invite)
      : this(
            event: event,
            status: invite.status,
            type: invite.type,
            title: invite.title,
            invitingUser: invite.invitingUser);

  HangEventInvite.withUserInvite(HangEvent event, UserInvite userInvite)
      : this(
            event: event,
            status: userInvite.status,
            type: userInvite.type,
            title: userInvite.title,
            invitingUser: userInvite.invitingUser);

  HangEventInvite copyWith(
      {HangEvent? event,
      InviteStatus? status,
      InviteType? type,
      InviteTitle? title,
      HangUserPreview? invitingUser,
      DateTime? eventStartDateTime,
      DateTime? eventEndDateTime}) {
    return HangEventInvite(
        event: event ?? this.event,
        status: status ?? this.status,
        type: type ?? this.type,
        title: title ?? this.title,
        invitingUser: invitingUser ?? this.invitingUser,
        eventStartDateTime: eventStartDateTime ?? this.eventStartDateTime,
        eventEndDateTime: eventEndDateTime ?? this.eventEndDateTime);
  }

  static HangEventInvite fromMap(Map<String, dynamic> map) {
    Invite invite = Invite.fromMap(map);

    HangEventInvite group = HangEventInvite(
        event: HangEvent.fromMap(map["event"]),
        status: invite.status,
        type: invite.type,
        title: invite.title,
        invitingUser: invite.invitingUser,
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
    final inviteToDocument = super.toDocument();
    return {
      "event": event.toDocument(),
      "eventStartDateTime": eventStartDateTime != null
          ? Timestamp.fromDate(eventStartDateTime!)
          : null,
      "eventEndDateTime": eventEndDateTime != null
          ? Timestamp.fromDate(eventEndDateTime!)
          : null,
      ...inviteToDocument
    };
  }

  @override
  List<Object?> get props => [
        event,
        status,
        type,
        title,
        invitingUser,
        eventStartDateTime,
        eventEndDateTime
      ];
}
