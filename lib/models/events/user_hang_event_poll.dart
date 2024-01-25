import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/utils/firebase_utils.dart';

class UserHangEventPoll extends Equatable {
  final String? id;
  final String pollId;
  final String userId;
  final DateTime? completedDate;

  const UserHangEventPoll({
    this.id,
    required this.pollId,
    required this.userId,
    this.completedDate,
  });

  UserHangEventPoll copyWith(
      {String? id, String? pollId, String? userId, DateTime? completedDate}) {
    return UserHangEventPoll(
        id: id ?? this.id,
        pollId: pollId ?? this.pollId,
        userId: userId ?? this.userId,
        completedDate: completedDate ?? this.completedDate);
  }

  static UserHangEventPoll fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static UserHangEventPoll fromMap(Map<String, dynamic> map) {
    UserHangEventPoll model = UserHangEventPoll(
        id: map['id'],
        pollId: map['pollId'],
        userId: map['userId'],
        completedDate: map.getFromMap("completedDate", (key) => key.toDate()));

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'pollId': pollId,
      'userId': userId,
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null
    };
    return retVal;
  }

  @override
  List<Object?> get props => [id, pollId, userId, completedDate];
}
