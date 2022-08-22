import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'hang_user_preview_model.dart';

class HangEvent extends Equatable {
  final String id;
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  late final DateTime eventStartDate;
  late final DateTime eventEndDate;
  final List<UserInvite> userInvites;
  HangEvent(
      {this.id = '',
      required this.eventOwner,
      this.eventName = '',
      this.eventDescription = '',
      DateTime? eventStartDate,
      DateTime? eventEndDate,
      List<UserInvite>? userInvites})
      : this.userInvites = userInvites ?? [] {
    this.eventStartDate = eventStartDate ?? DateTime.now();
    this.eventEndDate = eventEndDate ?? DateTime.now();
  }

  HangEvent.withId(String id, HangEvent event)
      : this(
            id: id,
            eventOwner: event.eventOwner,
            eventName: event.eventName,
            eventDescription: event.eventDescription,
            eventEndDate: event.eventEndDate,
            eventStartDate: event.eventStartDate,
            userInvites: event.userInvites);

  static HangEvent fromSnapshot(DocumentSnapshot snap,
      [List<UserInvite>? eventInvites]) {
    return fromMap(snap.data()!, eventInvites);
  }

  static HangEvent fromMap(Map<String, dynamic> map,
      [List<UserInvite>? userInvites]) {
    Timestamp startDateTimestamp = map['eventStartDate'];
    Timestamp endDateTimestamp = map['eventEndDate'];
    HangEvent event = HangEvent(
        id: map["id"],
        eventOwner: HangUserPreview.fromMap(map["eventOwner"]),
        eventName: map['eventName'],
        eventDescription: map['eventDescription'],
        eventStartDate: startDateTimestamp.toDate(),
        eventEndDate: endDateTimestamp.toDate(),
        userInvites: userInvites ?? []);
    return event;
  }

  Map<String, Object> toDocument() {
    return {
      "id": id,
      'eventName': eventName,
      "eventOwner": eventOwner.toDocument(),
      'eventDescription': eventDescription,
      'eventStartDate': Timestamp.fromDate(eventStartDate),
      'eventEndDate': Timestamp.fromDate(eventEndDate),
    };
  }

  @override
  List<Object> get props => [
        id,
        eventOwner,
        eventName,
        eventDescription,
        eventStartDate,
        eventEndDate,
        userInvites
      ];
}
