part of 'invitations_bloc.dart';

@immutable
abstract class InvitationsEvent extends Equatable {
  const InvitationsEvent();

  @override
  List<Object> get props => [];
}

class StatusChangeInvitation extends InvitationsEvent {
  final String notificationId;
  final String email;
  final String entityId;
  final InviteType inviteType;
  const StatusChangeInvitation(
      {required this.notificationId,
      required this.email,
      required this.entityId,
      required this.inviteType});

  @override
  List<Object> get props => [notificationId, email, entityId, inviteType];
}

class AcceptInvitation extends StatusChangeInvitation {
  const AcceptInvitation(
      {required String notificationId,
      required String email,
      required String entityId,
      required InviteType inviteType})
      : super(
            notificationId: notificationId,
            email: email,
            entityId: entityId,
            inviteType: inviteType);
}

class RejectInvitation extends StatusChangeInvitation {
  const RejectInvitation(
      {required String notificationId,
      required String email,
      required String entityId,
      required InviteType inviteType})
      : super(
            notificationId: notificationId,
            email: email,
            entityId: entityId,
            inviteType: inviteType);
}

class MaybeInvitation extends StatusChangeInvitation {
  const MaybeInvitation(
      {required String notificationId,
      required String email,
      required String entityId,
      required InviteType inviteType})
      : super(
            notificationId: notificationId,
            email: email,
            entityId: entityId,
            inviteType: inviteType);
}
