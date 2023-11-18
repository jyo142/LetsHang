import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/pending_invites.dart';
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
        super(const InvitationsState(
            invitationsStateStatus: InvitationsStateStatus.initial)) {
    on<AcceptInvitation>((event, emit) async {
      emit(state.copyWith(
          invitationsStateStatus:
              InvitationsStateStatus.invitationStatusChangedLoading));
      emit(await _mapChangeInvitationStatusToState(event));
    });
    on<RejectInvitation>((event, emit) async {
      emit(state.copyWith(
          invitationsStateStatus:
              InvitationsStateStatus.invitationStatusChangedLoading));
      emit(await _mapChangeInvitationStatusToState(event));
    });
    on<MaybeInvitation>((event, emit) async {
      emit(state.copyWith(
          invitationsStateStatus:
              InvitationsStateStatus.invitationStatusChangedLoading));
      emit(await _mapChangeInvitationStatusToState(event));
    });
    on<LoadAllPendingInvites>((event, emit) async {
      emit(state.copyWith(
          invitationsStateStatus:
              InvitationsStateStatus.pendingInvitationsLoading));
      emit(await _mapLoadingAllPendingInvitesToState(event));
    });
    on<LoadPendingInvites>((event, emit) async {
      emit(state.copyWith(
          invitationsStateStatus:
              InvitationsStateStatus.pendingInvitationsLoading));
      emit(await _mapLoadingPendingInvitesToState(event));
    });
  }

  Future<InvitationsState> _mapLoadingAllPendingInvitesToState(
      LoadAllPendingInvites loadPendingInvitesEvent) async {
    try {
      PendingInvites allPendingInvites = await _invitesRepository
          .getAllPendingInvites(loadPendingInvitesEvent.userId);
      return state.copyWith(
          allPendingInvites: allPendingInvites,
          invitationsStateStatus:
              InvitationsStateStatus.pendingInvitationsRetrieved);
    } catch (e) {
      return state.copyWith(errorMessage: "Unable to load pending invites");
    }
  }

  Future<InvitationsState> _mapLoadingPendingInvitesToState(
      LoadPendingInvites loadPendingInvitesEvent) async {
    try {
      if (loadPendingInvitesEvent.inviteType == InviteType.event) {
        List<HangEventInvite> pendingEventInvites = await _invitesRepository
            .getEventPendingInvites(loadPendingInvitesEvent.userId);
        return state.copyWith(
            allPendingInvites:
                PendingInvites(eventInvites: pendingEventInvites),
            invitationsStateStatus:
                InvitationsStateStatus.pendingInvitationsRetrieved);
      }
      if (loadPendingInvitesEvent.inviteType == InviteType.group) {
        List<GroupInvite> pendingGroupInvites = await _invitesRepository
            .getGroupPendingInvites(loadPendingInvitesEvent.userId);
        return state.copyWith(
            allPendingInvites:
                PendingInvites(groupInvites: pendingGroupInvites),
            invitationsStateStatus:
                InvitationsStateStatus.pendingInvitationsRetrieved);
      }
      return state;
    } catch (e) {
      return state.copyWith(errorMessage: "Unable to load pending invites");
    }
  }

  Future<InvitationsState> _mapChangeInvitationStatusToState(
      InvitationsEvent invitationsEvent) async {
    try {
      String finalMessage = "";
      StatusChangeInvitation statusChangeInvitationEvent =
          invitationsEvent as StatusChangeInvitation;
      if (invitationsEvent is AcceptInvitation) {
        await _invitesRepository.acceptInvite(invitationsEvent.inviteType,
            invitationsEvent.userId, invitationsEvent.entityId);
        finalMessage =
            'Successfully accepted the invitiation for the ${describeEnum(statusChangeInvitationEvent.inviteType)}';
      } else if (invitationsEvent is RejectInvitation) {
        await _invitesRepository.rejectInvite(invitationsEvent.inviteType,
            invitationsEvent.userId, invitationsEvent.entityId);
        finalMessage =
            'Successfully rejected the invitiation for the ${describeEnum(statusChangeInvitationEvent.inviteType)}';
      } else {
        await _invitesRepository.maybeInvite(invitationsEvent.inviteType,
            invitationsEvent.userId, invitationsEvent.entityId);
        finalMessage =
            'Successfully responded as tentative to the invitiation for the ${describeEnum(statusChangeInvitationEvent.inviteType)}';
      }
      // remove the notification
      if (statusChangeInvitationEvent.notificationId != null) {
        await _notificationsRepository.removeNotificationForUser(
            statusChangeInvitationEvent.userId,
            statusChangeInvitationEvent.notificationId!);
      } else {
        await _notificationsRepository.removeEntityNotificationForUser(
            statusChangeInvitationEvent.userId,
            statusChangeInvitationEvent.entityId,
            statusChangeInvitationEvent.inviteType);
      }

      return state.copyWith(
          invitationsStateStatus:
              InvitationsStateStatus.invitationStatusChangedSuccess,
          invitationStatusChangedSuccessMessage: finalMessage);
    } catch (e) {
      return state.copyWith(errorMessage: "Unable to change status");
    }
  }
}
