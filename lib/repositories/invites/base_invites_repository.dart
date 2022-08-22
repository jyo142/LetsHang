import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';

abstract class BaseInvitesRepository {
  Future<List<HangEventInvite>> getEventInvites(String userName);
  Future<void> addEventUserInvites(
      HangEvent hangEvent, List<UserInvite> userInvites);
  Future<void> editEventUserInvites(HangEvent hangEvent);
}
