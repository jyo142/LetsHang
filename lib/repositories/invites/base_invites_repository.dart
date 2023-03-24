import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';

abstract class BaseUserInvitesRepository {
  Future<List<HangEventInvite>> getUserEventInvites(String email);
  Future<void> addUserEventInvite(HangEvent hangEvent, UserInvite userInvite);
  Future<void> addUserEventInvites(
      HangEvent hangEvent, List<UserInvite> userInvites);
  Future<void> editUserEventInvites(HangEvent hangEvent);
}
