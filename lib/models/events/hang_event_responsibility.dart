import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class HangEventResponsibility extends Equatable {
  final String? id;
  final String responsibilityContent;
  final HangUserPreview assignedUser;
  final DateTime creationDate;
  final HangEventPreview? event;
  final DateTime? completedDate;

  const HangEventResponsibility(
      {this.id,
      required this.responsibilityContent,
      required this.assignedUser,
      required this.creationDate,
      this.event,
      this.completedDate});

  HangEventResponsibility.withId(
      String id, HangEventResponsibility hangEventResponsibility)
      : this(
            id: id,
            responsibilityContent:
                hangEventResponsibility.responsibilityContent,
            assignedUser: hangEventResponsibility.assignedUser,
            creationDate: hangEventResponsibility.creationDate,
            event: hangEventResponsibility.event,
            completedDate: hangEventResponsibility.completedDate);

  HangEventResponsibility copyWith(
      {String? id,
      String? messageContent,
      HangUserPreview? assignedUser,
      DateTime? creationDate,
      HangEventPreview? event,
      DateTime? completedDate}) {
    return HangEventResponsibility(
        id: id ?? this.id,
        responsibilityContent: messageContent ?? this.responsibilityContent,
        assignedUser: assignedUser ?? this.assignedUser,
        creationDate: creationDate ?? this.creationDate,
        event: event ?? this.event,
        completedDate: completedDate ?? this.completedDate);
  }

  static HangEventResponsibility fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static HangEventResponsibility fromMap(Map<String, dynamic> map) {
    HangEventResponsibility model = HangEventResponsibility(
        id: map['id'],
        responsibilityContent: map['responsibilityContent'],
        assignedUser: HangUserPreview.fromMap(map['assignedUser']),
        creationDate: map["creationDate"].toDate(),
        event: HangEventPreview.fromMap(map["event"]),
        completedDate: map.getFromMap("completedDate", (key) => key.toDate()));

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'responsibilityContent': responsibilityContent,
      'assignedUser': assignedUser.toDocument(),
      'creationDate': Timestamp.fromDate(creationDate),
      'event': event?.toDocument(),
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null
    };
    return retVal;
  }

  @override
  List<Object?> get props => [
        id,
        responsibilityContent,
        assignedUser,
        creationDate,
        event,
        completedDate
      ];
}
