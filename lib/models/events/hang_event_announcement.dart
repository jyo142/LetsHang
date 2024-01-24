import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class HangEventAnnouncement extends Equatable {
  final String? id;
  final String announcementContent;
  final HangUserPreview creatingUser;
  final DateTime creationDate;

  const HangEventAnnouncement({
    this.id,
    required this.announcementContent,
    required this.creatingUser,
    required this.creationDate,
  });

  HangEventAnnouncement.withId(
      String id, HangEventAnnouncement hangEventAnnouncement)
      : this(
          id: id,
          announcementContent: hangEventAnnouncement.announcementContent,
          creatingUser: hangEventAnnouncement.creatingUser,
          creationDate: hangEventAnnouncement.creationDate,
        );

  HangEventAnnouncement copyWith({
    String? id,
    String? announcementContent,
    HangUserPreview? creatingUser,
    DateTime? creationDate,
  }) {
    return HangEventAnnouncement(
      id: id ?? this.id,
      announcementContent: announcementContent ?? this.announcementContent,
      creatingUser: creatingUser ?? this.creatingUser,
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
      creatingUser: HangUserPreview.fromMap(map['creatingUser']),
      creationDate: map["creationDate"].toDate(),
    );

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'announcementContent': announcementContent,
      'creatingUser': creatingUser.toDocument(),
      'creationDate': Timestamp.fromDate(creationDate),
    };
    return retVal;
  }

  @override
  List<Object?> get props =>
      [id, announcementContent, creatingUser, creationDate];
}
