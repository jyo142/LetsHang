import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/has_user_invites.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'hang_user_preview_model.dart';

enum HangEventType { public, private }

enum HangEventStage { started, mainDetails, addingUsers, complete }

class HangEvent extends HasUserInvites {
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  late final DateTime? eventStartDateTime;
  late final DateTime? eventEndDateTime;
  final HangEventStage currentStage;
  final String? photoURL;
  HangEvent(
      {id,
      required this.eventOwner,
      this.eventName = '',
      this.eventDescription = '',
      this.eventStartDateTime,
      this.eventEndDateTime,
      List<UserInvite>? userInvites,
      this.currentStage = HangEventStage.started,
      this.photoURL = ''})
      : super(id, userInvites);

  HangEvent.withId(String id, HangEvent event)
      : this(
            id: id,
            eventOwner: event.eventOwner,
            eventName: event.eventName,
            eventDescription: event.eventDescription,
            eventEndDateTime: event.eventEndDateTime,
            eventStartDateTime: event.eventStartDateTime,
            userInvites: event.userInvites,
            currentStage: event.currentStage,
            photoURL: event.photoURL);

  static HangEvent fromSnapshot(DocumentSnapshot snap,
      [List<UserInvite>? eventInvites]) {
    return fromMap(snap.data() as Map<String, dynamic>, eventInvites);
  }

  HangEvent copyWith(
      {String? id,
      HangUserPreview? eventOwner,
      String? eventName,
      String? eventDescription,
      DateTime? eventStartDateTime,
      DateTime? eventEndDateTime,
      List<UserInvite>? userInvites,
      HangEventStage? currentStage,
      String? photoUrl}) {
    return HangEvent(
        id: id ?? this.id,
        eventOwner: eventOwner ?? this.eventOwner,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        eventStartDateTime: eventStartDateTime ?? this.eventStartDateTime,
        eventEndDateTime: eventEndDateTime ?? this.eventEndDateTime,
        userInvites: userInvites ?? this.userInvites,
        currentStage: currentStage ?? this.currentStage,
        photoURL: photoURL ?? this.photoURL);
  }

  static HangEvent fromMap(Map<String, dynamic> map,
      [List<UserInvite>? userInvites]) {
    Timestamp? startDateTimestamp = map['eventStartDateTime'];
    Timestamp? endDateTimestamp = map['eventEndDateTime'];
    HangEvent event = HangEvent(
        id: map["id"],
        eventOwner: HangUserPreview.fromMap(map["eventOwner"]),
        eventName: map['eventName'],
        eventDescription: map['eventDescription'],
        eventStartDateTime: startDateTimestamp?.toDate(),
        eventEndDateTime: endDateTimestamp?.toDate(),
        userInvites: userInvites ?? [],
        currentStage: HangEventStage.values
            .firstWhere((e) => describeEnum(e) == map["currentStage"]),
        photoURL: map['photoUrl']);
    return event;
  }

  Map<String, Object?> toDocument() {
    return {
      "id": id,
      'eventName': eventName,
      "eventOwner": eventOwner.toDocument(),
      'eventDescription': eventDescription,
      'eventStartDateTime': eventStartDateTime != null
          ? Timestamp.fromDate(eventStartDateTime!)
          : null,
      'eventEndDateTime': eventEndDateTime != null
          ? Timestamp.fromDate(eventEndDateTime!)
          : null,
      'currentStage': describeEnum(currentStage),
      'photoUrl': photoURL.toString()
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventOwner,
        eventName,
        eventDescription,
        eventStartDateTime,
        eventEndDateTime,
        userInvites,
        currentStage,
        photoURL
      ];
}
