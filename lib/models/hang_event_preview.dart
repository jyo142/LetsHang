import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:equatable/equatable.dart';

class HangEventPreview extends Equatable {
  final String eventId;
  final String eventName;
  final String? eventDescription;
  final String? photoURL;
  const HangEventPreview(
      {id,
      required this.eventId,
      required this.eventName,
      this.eventDescription = '',
      this.photoURL = ''});

  static HangEventPreview fromSnapshot(DocumentSnapshot snap,
      [List<UserInvite>? eventInvites]) {
    return fromMap(snap.data() as Map<String, dynamic>, eventInvites);
  }

  HangEventPreview.fromEvent(HangEvent event)
      : this.eventId = event.id,
        this.eventName = event.eventName,
        this.eventDescription = event.eventDescription,
        this.photoURL = event.photoURL;

  HangEventPreview copyWith(
      {String? eventId,
      String? eventName,
      String? eventDescription,
      String? photoUrl}) {
    return HangEventPreview(
        eventId: eventId ?? this.eventId,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        photoURL: photoURL ?? this.photoURL);
  }

  static HangEventPreview fromMap(Map<String, dynamic> map,
      [List<UserInvite>? userInvites]) {
    HangEventPreview event = HangEventPreview(
        eventId: map["eventId"],
        eventName: map['eventName'],
        eventDescription: map['eventDescription'],
        photoURL: map['photoUrl']);
    return event;
  }

  Map<String, Object?> toDocument() {
    return {
      "eventId": eventId,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'photoUrl': photoURL.toString()
    };
  }

  @override
  List<Object?> get props => [eventId, eventName, eventDescription, photoURL];
}
