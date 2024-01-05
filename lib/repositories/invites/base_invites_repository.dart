import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/pending_invites.dart';
import 'package:letshang/models/user_event_metadata.dart';
import 'package:letshang/models/user_invite_model.dart';

abstract class BaseUserInvitesRepository {
  Future<List<HangEventInvite>> getAllUserEventInvites(String userId);
  Future<List<HangEventInvite>> getUpcomingDraftEventInvites(String userId);
  Future<List<HangEventInvite>> getPastEventInvites(String userId);

  Future<List<HangEventInvite>> getUserEventInvitesByRange(
      String userId, DateTime startDateTime, DateTime endDateTime);
  Future<UserEventMetadata> getUserEventMetadata(String userId);

  // this method gets all the group invites for a user
  Future<List<GroupInvite>> getUserGroupInvites(String userId);

  // event invites
  // this method creates all the user invites for an event
  Future<void> addUserEventInvite(HangEvent hangEvent, UserInvite userInvite);
  Future<void> removeUserEventInvite(
      HangEvent hangEvent, UserInvite toRemoveUserInvite);

  Future<void> addUserEventInvites(
      HangEvent hangEvent, List<UserInvite> userInvites);
  Future<void> removeUserEventInvites(
      HangEvent hangEvent, List<UserInvite> toRemoveUserInvites);
  Future<void> promoteUserEventInvite(
      HangEvent hangEvent, UserInvite toPromote);

  // group invites
  // this method creates all the user invites for a group
  Future<void> addUserGroupInvite(Group group, UserInvite userInvite);
  Future<void> removeUserGroupInvite(
      Group group, UserInvite toRemoveUserInvite);
  Future<void> addUserGroupInvites(Group group, List<UserInvite> userInvites);
  Future<void> removeUserGroupInvites(
      Group group, List<UserInvite> toRemoveUserInvites);
  Future<void> promoteUserGroupInvite(Group group, UserInvite toPromote);

  Future<void> editUserGroupInvites(Group group);
  Future<bool> hasEventInviteConflict(
      String userId, DateTime? startDateTime, DateTime? endDateTime);

  // accept/invite/maybe
  Future<void> acceptInvite(
      InviteType inviteType, String userId, String entityId);
  Future<void> rejectInvite(
      InviteType inviteType, String userId, String entityId);
  Future<void> maybeInvite(
      InviteType inviteType, String userId, String entityId);

  // pending invites
  Future<PendingInvites> getAllPendingInvites(String userId);
  Future<List<GroupInvite>> getGroupPendingInvites(String userId);
  Future<List<HangEventInvite>> getEventPendingInvites(String userId);

  // accepted invites
  Future<List<UserInvite>> getEventAcceptedUserInvites(String eventId);
  Future<List<UserInvite>> getGroupAcceptedUserInvites(String groupId);
}
