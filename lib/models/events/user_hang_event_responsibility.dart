import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/utils/firebase_utils.dart';

class UserHangEventResponsibility extends Equatable {
  final String? id;
  final String eventResponsibilityId;
  final String userId;
  final DateTime? completedDate;

  const UserHangEventResponsibility({
    this.id,
    required this.eventResponsibilityId,
    required this.userId,
    this.completedDate,
  });

  UserHangEventResponsibility copyWith(
      {String? id,
      String? eventResponsibilityId,
      String? userId,
      DateTime? completedDate}) {
    return UserHangEventResponsibility(
        id: id ?? this.id,
        eventResponsibilityId:
            eventResponsibilityId ?? this.eventResponsibilityId,
        userId: userId ?? this.userId,
        completedDate: completedDate ?? this.completedDate);
  }

  static UserHangEventResponsibility fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static UserHangEventResponsibility fromMap(Map<String, dynamic> map) {
    UserHangEventResponsibility model = UserHangEventResponsibility(
        id: map['id'],
        eventResponsibilityId: map['eventResponsibilityId'],
        userId: map['userId'],
        completedDate: map.getFromMap("completedDate", (key) => key.toDate()));

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'eventResponsibilityId': eventResponsibilityId,
      'userId': userId,
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null
    };
    return retVal;
  }

  @override
  List<Object?> get props => [id, eventResponsibilityId, userId, completedDate];
}
