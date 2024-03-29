import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/discussions/discussion_metadata.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/discussions/event_discussions_model.dart';
import 'package:letshang/models/discussions/user_discussions_model.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/group_preview.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';

abstract class BaseDiscussionsRepository {
  // event discussions
  Future<List<DiscussionModel>> getEventDiscussions(String eventId);
  Future<void> addEventDiscussion(
    HangEventPreview event,
    bool isMainDiscussion,
    List<HangUserPreview> discussionMembers,
  );
  Future<void> addUserToEventMainDiscussion(
      String eventId, HangUserPreview newUser);
  Future<void> addUsersToEventMainDiscussion(
      String eventId, List<HangUserPreview> allNewUsers);

  // group discussions
  Future<DiscussionModel> getGroupDiscussion(String groupId);
  Future<void> addGroupDiscussion(
    GroupPreview group,
    List<HangUserPreview> discussionMembers,
  );
  Future<void> addUserToGroupDiscussion(
      String groupId, HangUserPreview newUser);
  Future<void> addUsersToGroupDiscussion(
      String groupId, List<HangUserPreview> allNewUsers);

  // discussion messages
  Stream<List<DiscussionMessage>> getMessagesForDiscussion(String discussionId);
  Future<void> sendMessageForDiscussion(
      String discussionId, HangUserPreview sendingUser, String message);

  // user discussions
  Future<List<UserDiscussionsModel>> getUserDiscussions(String userId);
}
