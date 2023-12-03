import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/group_preview.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class UserDiscussionsModel extends DiscussionModel {
  final String userId;

  const UserDiscussionsModel(
      {required this.userId,
      required discussionId,
      required discussionMembers,
      lastMessage,
      isMainDiscussion,
      event,
      group})
      : super(
            discussionId: discussionId,
            discussionMembers: discussionMembers,
            isMainDiscussion: isMainDiscussion,
            lastMessage: lastMessage,
            group: group,
            event: event);

  static UserDiscussionsModel fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  UserDiscussionsModel copyWithUserDiscussion({
    String? userId,
    String? discussionId,
    List<HangUserPreview>? discussionMembers,
    HangEventPreview? event,
    DiscussionMessage? lastMessage,
    GroupPreview? group,
  }) {
    return UserDiscussionsModel(
        userId: userId ?? this.userId,
        discussionId: discussionId ?? this.discussionId,
        discussionMembers: discussionMembers ?? this.discussionMembers,
        lastMessage: lastMessage ?? this.lastMessage,
        event: event ?? this.event,
        group: group ?? this.group);
  }

  static UserDiscussionsModel fromMap(Map<String, dynamic> map) {
    DiscussionModel discussionModel = DiscussionModel.fromMap(map);
    UserDiscussionsModel notification = UserDiscussionsModel(
        userId: map['userId'],
        discussionMembers: discussionModel.discussionMembers,
        isMainDiscussion: discussionModel.isMainDiscussion,
        discussionId: discussionModel.discussionId,
        lastMessage: discussionModel.lastMessage,
        event: discussionModel.event,
        group: discussionModel.group);

    return notification;
  }

  Map<String, Object?> toDocument() {
    final discussionModelToDocument = super.toDocument();

    Map<String, Object?> retVal = {
      'userId': userId,
      ...discussionModelToDocument
    };
    return retVal;
  }

  @override
  List<Object?> get props => [userId];
}
