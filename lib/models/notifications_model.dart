import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsModel extends Equatable {
  final String id;
  final String userEmail;
  final String content;
  final DateTime createdDate;
  final String? eventId;
  final String? groupId;

  const NotificationsModel(
      {required this.id,
      required this.userEmail,
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
        id: map['id'],
        userEmail: map["userEmail"],
        content: map['content'],
        createdDate: createdDateTimestamp.toDate(),
        eventId: map.containsKey('eventId') ? map['eventId'] : null,
        groupId: map.containsKey('groupId') ? map['groupId'] : null);

    return notification;
  }

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'userEmail': userEmail,
      'content': content,
      "createdDate": Timestamp.fromDate(createdDate),
      'eventId': eventId,
      'groupId': groupId,
    };
  }

  @override
  List<Object?> get props => [userEmail, content, eventId, groupId];
}
