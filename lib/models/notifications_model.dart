import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/utils/firebase_utils.dart';

class NotificationsModel extends Equatable {
  final String id;
  final String userEmail;
  final String content;
  final DateTime createdDate;
  final DateTime? expirationDate;
  final String? eventId;
  final String? groupId;
  final String? initiatedUserName;
  final String? initiatedUserPhotoUrl;
  const NotificationsModel(
      {required this.id,
      required this.userEmail,
      required this.content,
      required this.createdDate,
      this.expirationDate,
      this.eventId,
      this.groupId,
      this.initiatedUserName,
      this.initiatedUserPhotoUrl});

  NotificationsModel.withId(String id, NotificationsModel notificationsModel)
      : this(
            id: id,
            userEmail: notificationsModel.userEmail,
            content: notificationsModel.content,
            createdDate: notificationsModel.createdDate,
            expirationDate: notificationsModel.expirationDate,
            eventId: notificationsModel.eventId,
            groupId: notificationsModel.groupId,
            initiatedUserName: notificationsModel.initiatedUserName,
            initiatedUserPhotoUrl: notificationsModel.initiatedUserPhotoUrl);

  static NotificationsModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static NotificationsModel fromMap(Map<String, dynamic> map) {
    Timestamp createdDateTimestamp = map['createdDate'];
    Timestamp? expirationDateTimestamp =
        map.containsKey("expirationDate") ? map['expirationDate'] : null;
    NotificationsModel notification = NotificationsModel(
        id: map['id'],
        userEmail: map["userEmail"],
        content: map['content'],
        createdDate: createdDateTimestamp.toDate(),
        expirationDate: expirationDateTimestamp?.toDate(),
        eventId: map.containsKey('eventId') ? map['eventId'] : null,
        groupId: map.containsKey('groupId') ? map['groupId'] : null,
        initiatedUserName: map.containsKey('initiatedUserName')
            ? map['initiatedUserName']
            : null,
        initiatedUserPhotoUrl: map.containsKey('initiatedUserPhotoUrl')
            ? map['initiatedUserPhotoUrl']
            : null);

    return notification;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'userEmail': userEmail,
      'content': content,
      "createdDate": Timestamp.fromDate(createdDate),
      'eventId': eventId,
      'groupId': groupId,
      'initiatedUserName': initiatedUserName,
      'initiatedUserPhotoUrl': initiatedUserPhotoUrl
    };
    if (expirationDate != null) {
      retVal["expirationDate"] = Timestamp.fromDate(expirationDate!);
    }
    return retVal;
  }

  @override
  List<Object?> get props => [
        id,
        userEmail,
        content,
        eventId,
        groupId,
        createdDate,
        expirationDate,
        initiatedUserName,
        initiatedUserPhotoUrl,
      ];
}
