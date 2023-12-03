import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/group_preview.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/utils/firebase_utils.dart';

class DiscussionModel extends Equatable {
  final String? id;
  final String discussionId;
  final bool? isMainDiscussion;
  final List<HangUserPreview> discussionMembers;
  final DiscussionMessage? lastMessage;
  final HangEventPreview? event;
  final GroupPreview? group;

  const DiscussionModel(
      {this.id,
      required this.discussionId,
      this.isMainDiscussion,
      required this.discussionMembers,
      this.lastMessage,
      this.group,
      this.event});

  DiscussionModel.withId(String id, DiscussionModel discussionsModel)
      : this(
            id: id,
            discussionId: discussionsModel.discussionId,
            isMainDiscussion: discussionsModel.isMainDiscussion,
            discussionMembers: discussionsModel.discussionMembers,
            lastMessage: discussionsModel.lastMessage,
            group: discussionsModel.group,
            event: discussionsModel.event);

  DiscussionModel copyWith({
    String? id,
    String? discussionId,
    bool? isMainGroupDiscussion,
    List<HangUserPreview>? discussionMembers,
    DiscussionMessage? lastMessage,
    GroupPreview? group,
    HangEventPreview? event,
  }) {
    return DiscussionModel(
        id: id ?? this.id,
        discussionId: discussionId ?? this.discussionId,
        isMainDiscussion: isMainGroupDiscussion ?? this.isMainDiscussion,
        discussionMembers: discussionMembers ?? this.discussionMembers,
        lastMessage: lastMessage ?? this.lastMessage,
        group: group,
        event: event);
  }

  static DiscussionModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static DiscussionModel fromMap(Map<String, dynamic> map) {
    DiscussionModel notification = DiscussionModel(
      id: map['id'],
      discussionId: map['discussionId'],
      isMainDiscussion: map["isMainDiscussion"],
      discussionMembers: (map['discussionMembers'] as List<dynamic>)
          .map((member) => HangUserPreview.fromMap(member))
          .toList(),
      lastMessage: map.getFromMap(
          "lastMessage", (key) => DiscussionMessage.fromMap(key)),
      group: map.getFromMap("group", (key) => GroupPreview.fromMap(key)),
      event: map.getFromMap("event", (key) => HangEventPreview.fromMap(key)),
    );

    return notification;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'id': id,
      'discussionId': discussionId,
      'isMainDiscussion': isMainDiscussion,
      'discussionMembers':
          discussionMembers.map((member) => member.toDocument()).toList(),
      'lastMessage': lastMessage?.toDocument(),
      'group': group?.toDocument(),
      'event': event?.toDocument()
    };
    return retVal;
  }

  @override
  List<Object?> get props => [
        id,
        discussionId,
        isMainDiscussion,
        discussionMembers,
        lastMessage,
        group,
        event
      ];
}
