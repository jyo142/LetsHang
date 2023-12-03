import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class EventDiscussionModel extends Equatable {
  final String? id;
  final DiscussionModel eventDiscussionModel;
  final String eventId;

  const EventDiscussionModel(
      {this.id, required this.eventDiscussionModel, required this.eventId});

  EventDiscussionModel.withId(String id, EventDiscussionModel discussionModel)
      : this(
          id: id,
          eventDiscussionModel: discussionModel.eventDiscussionModel,
          eventId: discussionModel.eventId,
        );

  static EventDiscussionModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  EventDiscussionModel copyWith({
    String? id,
    DiscussionModel? eventDiscussionModel,
    String? eventId,
  }) {
    return EventDiscussionModel(
      id: id ?? this.id,
      eventDiscussionModel: eventDiscussionModel ?? this.eventDiscussionModel,
      eventId: eventId ?? this.eventId,
    );
  }

  static EventDiscussionModel fromMap(Map<String, dynamic> map) {
    EventDiscussionModel notification = EventDiscussionModel(
      id: map['id'],
      eventDiscussionModel:
          DiscussionModel.fromMap(map['eventDiscussionModel']),
      eventId: map['eventId'],
    );

    return notification;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'eventDiscussionModel': eventDiscussionModel.toDocument(),
      'eventId': eventId,
    };
    return retVal;
  }

  @override
  List<Object?> get props => [
        id,
        eventDiscussionModel,
        eventId,
      ];
}
