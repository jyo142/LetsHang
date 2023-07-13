import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsModel extends Equatable {
  final String userEmail;
  final bool hasRead;
  final String content;
  final DateTime createdDate;
  final String? eventId;
  final String? groupId;

  const NotificationsModel(
      {required this.userEmail,
      required this.hasRead,
      required this.content,
      required this.createdDate,
      this.eventId,
      this.groupId});

  static NotificationsModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data()!);
  }

  static NotificationsModel fromMap(Map<String, dynamic> map) {
    Timestamp createdDateTimestamp = map['createdDate'];
    NotificationsModel notification = NotificationsModel(
        userEmail: map["userEmail"],
        hasRead: map["hasRead"],
        content: map['content'],
        createdDate: createdDateTimestamp.toDate(),
        eventId: map.containsKey('eventId') ? map['eventId'] : null,
        groupId: map.containsKey('groupId') ? map['groupId'] : null);

    return notification;
  }

  Map<String, Object?> toDocument() {
    return {
      'userEmail': userEmail,
      "hasRead": hasRead,
      'content': content,
      "createdDate": Timestamp.fromDate(createdDate),
      'eventId': eventId,
      'groupId': groupId,
    };
  }

  @override
  List<Object?> get props => [userEmail, hasRead, content, eventId, groupId];
}
