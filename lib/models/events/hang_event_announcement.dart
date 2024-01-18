import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HangEventAnnouncement extends Equatable {
  final String? id;
  final String announcementContent;
  final DateTime creationDate;

  const HangEventAnnouncement({
    this.id,
    required this.announcementContent,
    required this.creationDate,
  });

  HangEventAnnouncement.withId(
      String id, HangEventAnnouncement hangEventAnnouncement)
      : this(
          id: id,
          announcementContent: hangEventAnnouncement.announcementContent,
          creationDate: hangEventAnnouncement.creationDate,
        );

  HangEventAnnouncement copyWith({
    String? id,
    String? announcementContent,
    DateTime? creationDate,
  }) {
    return HangEventAnnouncement(
      id: id ?? this.id,
      announcementContent: announcementContent ?? this.announcementContent,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  static HangEventAnnouncement fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static HangEventAnnouncement fromMap(Map<String, dynamic> map) {
    HangEventAnnouncement model = HangEventAnnouncement(
      id: map['id'],
      announcementContent: map['announcementContent'],
      creationDate: map["creationDate"].toDate(),
    );

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'announcementContent': announcementContent,
      'creationDate': Timestamp.fromDate(creationDate),
    };
    return retVal;
  }

  @override
  List<Object?> get props => [id, announcementContent, creationDate];
}
