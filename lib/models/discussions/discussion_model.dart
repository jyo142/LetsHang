import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class DiscussionModel extends Equatable {
  final String? id;
  final String discussionId;
  final bool isMainGroupDiscussion;
  final List<HangUserPreview> discussionMembers;
  final String? eventId;

  const DiscussionModel(
      {this.id,
      required this.discussionId,
      required this.isMainGroupDiscussion,
      required this.discussionMembers,
      this.eventId});

  DiscussionModel.withId(String id, DiscussionModel discussionsModel)
      : this(
          id: id,
          discussionId: discussionsModel.discussionId,
          isMainGroupDiscussion: discussionsModel.isMainGroupDiscussion,
          discussionMembers: discussionsModel.discussionMembers,
          eventId: discussionsModel.eventId,
        );

  DiscussionModel copyWith({
    String? id,
    String? discussionId,
    bool? isMainGroupDiscussion,
    List<HangUserPreview>? discussionMembers,
    String? eventId,
  }) {
    return DiscussionModel(
      id: id ?? this.id,
      discussionId: discussionId ?? this.discussionId,
      isMainGroupDiscussion:
          isMainGroupDiscussion ?? this.isMainGroupDiscussion,
      discussionMembers: discussionMembers ?? this.discussionMembers,
      eventId: eventId ?? this.eventId,
    );
  }

  static DiscussionModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static DiscussionModel fromMap(Map<String, dynamic> map) {
    DiscussionModel notification = DiscussionModel(
      id: map['id'],
      discussionId: map['discussionId'],
      isMainGroupDiscussion: map["isMainGroupDiscussion"],
      discussionMembers: (map['discussionMembers'] as List<dynamic>)
          .map((member) => HangUserPreview.fromMap(member))
          .toList(),
      eventId: map['eventId'],
    );

    return notification;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'discussionId': discussionId,
      'isMainGroupDiscussion': isMainGroupDiscussion,
      'discussionMembers':
          discussionMembers.map((member) => member.toDocument()).toList(),
      'eventId': eventId,
    };
    return retVal;
  }

  @override
  List<Object?> get props => [
        id,
        discussionId,
        isMainGroupDiscussion,
        discussionMembers,
        eventId,
      ];
}
