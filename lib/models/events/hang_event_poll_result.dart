import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class PollOptionToResults {
  final String pollOption;
  final List<HangEventPollResult> pollResults;

  PollOptionToResults({required this.pollOption, required this.pollResults});
}

class HangEventPollResult extends Equatable {
  final String? id;
  final String pollId;
  final HangUserPreview pollUser;
  final DateTime creationDate;
  final String pollResult;

  const HangEventPollResult(
      {this.id,
      required this.pollId,
      required this.pollUser,
      required this.creationDate,
      required this.pollResult});

  HangEventPollResult.withId(String id, HangEventPollResult hangEventPollResult)
      : this(
          id: id,
          pollId: hangEventPollResult.pollId,
          pollUser: hangEventPollResult.pollUser,
          creationDate: hangEventPollResult.creationDate,
          pollResult: hangEventPollResult.pollResult,
        );

  HangEventPollResult copyWith(
      {String? id,
      String? pollId,
      HangUserPreview? pollUser,
      DateTime? creationDate,
      String? pollResult}) {
    return HangEventPollResult(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      pollUser: pollUser ?? this.pollUser,
      creationDate: creationDate ?? this.creationDate,
      pollResult: pollResult ?? this.pollResult,
    );
  }

  static HangEventPollResult fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static HangEventPollResult fromMap(Map<String, dynamic> map) {
    HangEventPollResult model = HangEventPollResult(
        id: map['id'],
        pollId: map['pollId'],
        creationDate: map["creationDate"].toDate(),
        pollUser: HangUserPreview.fromMap(map["pollUser"]),
        pollResult: map['pollResult']);

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'pollId': pollId,
      'creationDate': Timestamp.fromDate(creationDate),
      'pollUser': pollUser.toDocument(),
      'pollResult': pollResult
    };
    return retVal;
  }

  @override
  List<Object?> get props => [id, pollId, pollUser, creationDate, pollResult];
}
