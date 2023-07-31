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
      if (invitationsEvent is AcceptInvitation) {
        await _invitesRepository.acceptInvite(invitationsEvent.inviteType,
            invitationsEvent.email, invitationsEvent.entityId);
        _notificationsRepository.removeNotificationForUser(
            invitationsEvent.email, invitationsEvent.notificationId);

        yield InvitationStatusChangedSuccess(
            successMessage:
                'Successfully accepted the invitiation for the ${describeEnum(invitationsEvent.inviteType)}');
      }
      if (invitationsEvent is RejectInvitation) {
        await _invitesRepository.rejectInvite(invitationsEvent.inviteType,
            invitationsEvent.email, invitationsEvent.entityId);
        _notificationsRepository.removeNotificationForUser(
            invitationsEvent.email, invitationsEvent.notificationId);

        yield InvitationStatusChangedSuccess(
            successMessage:
                'Successfully rejected the invitation for the ${describeEnum(invitationsEvent.inviteType)}');
      }
      if (invitationsEvent is MaybeInvitation) {
        await _invitesRepository.maybeInvite(invitationsEvent.inviteType,
            invitationsEvent.email, invitationsEvent.entityId);
        _notificationsRepository.removeNotificationForUser(
            invitationsEvent.email, invitationsEvent.notificationId);

        yield InvitationStatusChangedSuccess(
            successMessage:
                'Successfully responded maybe to the invitation for the ${describeEnum(invitationsEvent.inviteType)}');
      }
      // remove the notification
    } catch (e) {
      yield const InvitationStatusChangedError(
          errorMessage: "Unable to change status");
    }
  }
}
