import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/repositories/notifications/base_notifications_repository.dart';
import 'package:letshang/repositories/notifications/notifications_repository.dart';

part 'invitations_event.dart';
part 'invitations_state.dart';

class InvitationsBloc extends Bloc<InvitationsEvent, InvitationsState> {
  final BaseUserInvitesRepository _invitesRepository;
  final BaseNotificationsRepository _notificationsRepository;

  // constructor
  InvitationsBloc()
      : _invitesRepository = UserInvitesRepository(),
        _notificationsRepository = NotificationsRepository(),
        super(const InvitationsState());

  @override
  Stream<InvitationsState> mapEventToState(InvitationsEvent event) async* {
    if (event is AcceptInvitation ||
        event is RejectInvitation ||
        event is MaybeInvitation) {
      yield InvitationStatusChangedLoading();
      yield* _mapChangeInvitationStatusToState(event);
    }
  }

  Stream<InvitationsState> _mapChangeInvitationStatusToState(
      InvitationsEvent invitationsEvent) async* {
    try {
      String finalMessage = "";
      StatusChangeInvitation statusChangeInvitationEvent =
          invitationsEvent as StatusChangeInvitation;
      if (invitationsEvent is AcceptInvitation) {
        await _invitesRepository.acceptInvite(invitationsEvent.inviteType,
            invitationsEvent.email, invitationsEvent.entityId);
        finalMessage =
            'Successfully accepted the invitiation for the ${describeEnum(statusChangeInvitationEvent.inviteType)}';
      } else if (invitationsEvent is RejectInvitation) {
        await _invitesRepository.rejectInvite(invitationsEvent.inviteType,
            invitationsEvent.email, invitationsEvent.entityId);
        finalMessage =
            'Successfully rejected the invitiation for the ${describeEnum(statusChangeInvitationEvent.inviteType)}';
      } else {
        await _invitesRepository.maybeInvite(invitationsEvent.inviteType,
            invitationsEvent.email, invitationsEvent.entityId);
        finalMessage =
            'Successfully responded as tentative to the invitiation for the ${describeEnum(statusChangeInvitationEvent.inviteType)}';
      }
      // remove the notification
      await _notificationsRepository.removeNotificationForUser(
          statusChangeInvitationEvent.email,
          statusChangeInvitationEvent.notificationId);
      yield InvitationStatusChangedSuccess(successMessage: finalMessage);
    } catch (e) {
      yield const InvitationStatusChangedError(
          errorMessage: "Unable to change status");
    }
  }
}
