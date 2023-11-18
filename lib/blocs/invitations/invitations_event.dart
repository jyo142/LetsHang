part of 'invitations_bloc.dart';

@immutable
abstract class InvitationsEvent extends Equatable {
  const InvitationsEvent();

  @override
  List<Object?> get props => [];
}

class StatusChangeInvitation extends InvitationsEvent {
  final String userId;
  final String entityId;
  final InviteType inviteType;
  final String? notificationId;

  const StatusChangeInvitation({
    required this.userId,
    required this.entityId,
    required this.inviteType,
    this.notificationId,
  });

  @override
  List<Object?> get props => [notificationId, userId, entityId, inviteType];
}

class AcceptInvitation extends StatusChangeInvitation {
  const AcceptInvitation({
    required String userId,
    required String entityId,
    required InviteType inviteType,
    String? notificationId,
  }) : super(
            notificationId: notificationId,
            userId: userId,
            entityId: entityId,
            inviteType: inviteType);
}

class RejectInvitation extends StatusChangeInvitation {
  const RejectInvitation({
    required String userId,
    required String entityId,
    required InviteType inviteType,
    String? notificationId,
  }) : super(
            notificationId: notificationId,
            userId: userId,
            entityId: entityId,
            inviteType: inviteType);
}

class MaybeInvitation extends StatusChangeInvitation {
  const MaybeInvitation({
    required String userId,
    required String entityId,
    required InviteType inviteType,
    String? notificationId,
  }) : super(
            notificationId: notificationId,
            userId: userId,
            entityId: entityId,
            inviteType: inviteType);
}

class LoadAllPendingInvites extends InvitationsEvent {
  final String userId;
  const LoadAllPendingInvites({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadPendingInvites extends InvitationsEvent {
  final InviteType inviteType;
  final String userId;
  const LoadPendingInvites({required this.inviteType, required this.userId});

  @override
  List<Object> get props => [userId];
}
