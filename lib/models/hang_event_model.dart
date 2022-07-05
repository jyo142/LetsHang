import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/group_model.dart';

import 'hang_user_preview_model.dart';

class HangEvent extends Equatable {
  final String id;
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  late final DateTime eventStartDate;
  late final DateTime eventEndDate;
  final List<HangUserPreview> eventInvitees;
  final List<Group> eventGroupInvitees;

  HangEvent({
    this.id = '',
    required this.eventOwner,
    this.eventName = '',
    this.eventDescription = '',
    DateTime? eventStartDate,
    DateTime? eventEndDate,
    List<HangUserPreview>? eventInvitees,
    List<Group>? eventGroupInvitees,
  })  : this.eventInvitees = eventInvitees ?? [],
        this.eventGroupInvitees = eventGroupInvitees ?? [] {
    this.eventStartDate = eventStartDate ?? DateTime.now();
    this.eventEndDate = eventEndDate ?? DateTime.now();
  }

  static HangEvent fromSnapshot(DocumentSnapshot snap) {
    Timestamp startDateTimestamp = snap['startDateTime'];
    Timestamp endDateTimestamp = snap['endDateTime'];
    HangEvent event = HangEvent(
        id: snap.id,
        eventOwner: HangUserPreview.fromMap(snap["eventOwner"]),
        eventName: snap['name'],
        eventDescription: snap['description'],
        eventStartDate: startDateTimestamp.toDate(),
        eventEndDate: endDateTimestamp.toDate(),
        eventInvitees: List.of(snap["eventInvitees"])
            .map((m) => HangUserPreview.fromMap(m))
            .toList(),
        eventGroupInvitees: List.of(snap["eventGroupInvitees"])
            .map((m) => Group.fromMap(m))
            .toList());
    return event;
  }

  Map<String, Object> toDocument() {
    return {
      'name': eventName,
      "eventOwner": eventOwner.toDocument(),
      'description': eventDescription,
      'startDateTime': Timestamp.fromDate(eventStartDate),
      'endDateTime': Timestamp.fromDate(eventEndDate),
      "eventInvitees": eventInvitees.map((ei) => (ei.toDocument())).toList(),
      "eventInviteeIds": eventInvitees.map((ei) => ei.userName).toList(),
      "eventGroupInvitees":
          eventGroupInvitees.map((egi) => (egi.toDocument())).toList(),
      "eventGroupInviteeNames":
          eventGroupInvitees.map((egi) => (egi.groupName)).toList(),
    };
  }

  @override
  List<Object> get props => [
        id,
        eventOwner,
        eventName,
        eventDescription,
        eventStartDate,
        eventEndDate
      ];
}
