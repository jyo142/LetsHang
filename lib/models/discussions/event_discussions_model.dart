import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class EventDiscussionsModel extends Equatable {
  final String? id;
  final List<DiscussionModel> eventDiscussions;
  final String eventId;

  const EventDiscussionsModel(
      {this.id, required this.eventDiscussions, required this.eventId});

  EventDiscussionsModel.withId(
      String id, EventDiscussionsModel discussionsModel)
      : this(
          id: id,
          eventDiscussions: discussionsModel.eventDiscussions,
          eventId: discussionsModel.eventId,
        );

  static EventDiscussionsModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  EventDiscussionsModel copyWith({
    String? id,
    List<DiscussionModel>? eventDiscussions,
    String? eventId,
  }) {
    return EventDiscussionsModel(
      id: id ?? this.id,
      eventDiscussions: eventDiscussions ?? this.eventDiscussions,
      eventId: eventId ?? this.eventId,
    );
  }

  static EventDiscussionsModel fromMap(Map<String, dynamic> map) {
    EventDiscussionsModel notification = EventDiscussionsModel(
      id: map['id'],
      eventDiscussions: (map['eventDiscussions'] as List<dynamic>)
          .map((discussionMap) => DiscussionModel.fromMap(discussionMap))
          .toList(),
      eventId: map['eventId'],
    );

    return notification;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'eventDiscussions': eventDiscussions
          .map((discussion) => discussion.toDocument())
          .toList(),
      'eventId': eventId,
    };
    return retVal;
  }

  @override
  List<Object?> get props => [
        id,
        eventDiscussions,
        eventId,
      ];
}
