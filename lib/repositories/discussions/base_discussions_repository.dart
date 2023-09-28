import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/discussions/discussion_metadata.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/discussions/event_discussions_model.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';

abstract class BaseDiscussionsRepository {
  Future<EventDiscussionsModel?> getEventDiscussions(String eventId);
  Future<void> addEventDiscussion(
    String eventId,
    bool isMainGroupDiscussion,
    List<HangUserPreview> discussionMembers,
  );
  Future<void> addUserToEventGroupDiscussion(
      String eventId, HangUserPreview newUser);
  Future<void> addUsersToEventGroupDiscussion(
      String eventId, List<HangUserPreview> allNewUsers);

  Stream<List<DiscussionMessage>> getMessagesForDiscussion(String discussionId);
  Future<void> sendMessageForDiscussion(
      String discussionId, HangUserPreview sendingUser, String message);
}
