import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/utils/firebase_utils.dart';

class HangEventPoll extends Equatable {
  final String? id;
  final String pollName;
  final List<String> pollOptions;
  final DateTime creationDate;
  final DateTime? completedDate;
  final HangEventPreview? event;

  const HangEventPoll(
      {this.id,
      required this.pollName,
      required this.pollOptions,
      required this.creationDate,
      this.completedDate,
      this.event});

  HangEventPoll.withId(String id, HangEventPoll hangEventPoll)
      : this(
            id: id,
            pollName: hangEventPoll.pollName,
            pollOptions: hangEventPoll.pollOptions,
            creationDate: hangEventPoll.creationDate,
            event: hangEventPoll.event,
            completedDate: hangEventPoll.completedDate);

  HangEventPoll copyWith(
      {String? id,
      String? pollName,
      List<String>? pollOptions,
      DateTime? creationDate,
      HangEventPreview? event,
      DateTime? completedDate}) {
    return HangEventPoll(
        id: id ?? this.id,
        pollName: pollName ?? this.pollName,
        pollOptions: pollOptions ?? this.pollOptions,
        creationDate: creationDate ?? this.creationDate,
        event: event ?? this.event,
        completedDate: completedDate ?? this.completedDate);
  }

  static HangEventPoll fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static HangEventPoll fromMap(Map<String, dynamic> map) {
    HangEventPoll model = HangEventPoll(
        id: map['id'],
        pollName: map['pollName'],
        pollOptions: List<String>.from(map["pollOptions"]),
        creationDate: map["creationDate"].toDate(),
        event: HangEventPreview.fromMap(map["event"]),
        completedDate: map.getFromMap("completedDate", (key) => key.toDate()));

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'pollName': pollName,
      'pollOptions': pollOptions,
      'creationDate': Timestamp.fromDate(creationDate),
      'event': event?.toDocument(),
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null
    };
    return retVal;
  }

  @override
  List<Object?> get props =>
      [id, pollName, pollOptions, creationDate, event, completedDate];
}
