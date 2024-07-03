import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/events/hang_event_recurring_settings.dart';
import 'package:letshang/models/has_user_invites.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/utils/firebase_utils.dart';
import 'hang_user_preview_model.dart';

enum HangEventType { public, private }

enum HangEventStage {
  started,
  nameDescription,
  dateTime,
  recurringEvent,
  location,
  mainDetails,
  addingUsers,
  review,
  complete
}

class HangEvent extends HasUserInvites {
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  late final DateTime? eventStartDateTime;
  late final DateTime? eventEndDateTime;
  final int? durationHours;
  final String? eventLocation;
  final HangEventStage currentStage;
  final HangEventRecurringSettings? recurringSettings;
  final String? photoURL;
  final bool? isCancelled;
  HangEvent({
    id,
    required this.eventOwner,
    this.eventName = '',
    this.eventDescription = '',
    this.eventStartDateTime,
    this.eventEndDateTime,
    this.durationHours,
    this.eventLocation,
    List<UserInvite>? userInvites,
    this.currentStage = HangEventStage.started,
    this.recurringSettings,
    this.photoURL = '',
    this.isCancelled,
  }) : super(id, userInvites);

  HangEvent.withId(String id, HangEvent event)
      : this(
            id: id,
            eventOwner: event.eventOwner,
            eventName: event.eventName,
            eventDescription: event.eventDescription,
            eventEndDateTime: event.eventEndDateTime,
            eventStartDateTime: event.eventStartDateTime,
            durationHours: event.durationHours,
            eventLocation: event.eventLocation,
            userInvites: event.userInvites,
            currentStage: event.currentStage,
            recurringSettings: event.recurringSettings,
            photoURL: event.photoURL,
            isCancelled: event.isCancelled);

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
      int? durationHours,
      String? eventLocation,
      List<UserInvite>? userInvites,
      HangEventStage? currentStage,
      HangEventRecurringSettings? recurringSettings,
      String? photoUrl,
      bool? isCancelled}) {
    return HangEvent(
        id: id ?? this.id,
        eventOwner: eventOwner ?? this.eventOwner,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        eventStartDateTime: eventStartDateTime ?? this.eventStartDateTime,
        eventEndDateTime: eventEndDateTime ?? this.eventEndDateTime,
        durationHours: durationHours ?? this.durationHours,
        eventLocation: eventLocation ?? this.eventLocation,
        userInvites: userInvites ?? this.userInvites,
        currentStage: currentStage ?? this.currentStage,
        recurringSettings: recurringSettings ?? this.recurringSettings,
        photoURL: photoURL ?? this.photoURL,
        isCancelled: isCancelled ?? this.isCancelled);
  }

  bool isReadonlyEvent() {
    if (eventStartDateTime == null) {
      return false;
    }
    return eventStartDateTime!.isBefore(DateTime.now());
  }

  bool isCancelledEvent() {
    if (isCancelled == null) {
      return false;
    }
    return isCancelled!;
  }

  void validateEventWrite() {
    if (isReadonlyEvent() || isCancelledEvent()) {
      throw Exception("Unable to make changes to event");
    }
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
      durationHours: map.getFromMap("durationHours", (key) => key),
      eventLocation: map.getFromMap("eventLocation", (key) => key),
      userInvites: userInvites ?? [],
      currentStage: HangEventStage.values
          .firstWhere((e) => describeEnum(e) == map["currentStage"]),
      recurringSettings: map.getFromMap("recurringSettings",
          (key) => HangEventRecurringSettings.fromMap(key)),
      photoURL: map['photoUrl'],
      isCancelled: map.getFromMap("isCancelled", (key) => key),
    );
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
      'durationHours': durationHours,
      'eventLocation': eventLocation,
      'currentStage': describeEnum(currentStage),
      'recurringSettings':
          recurringSettings != null ? recurringSettings!.toDocument() : null,
      'photoUrl': photoURL.toString(),
      'isCancelled': isCancelled
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
        durationHours,
        eventLocation,
        userInvites,
        currentStage,
        recurringSettings,
        photoURL,
        isCancelled
      ];
}
