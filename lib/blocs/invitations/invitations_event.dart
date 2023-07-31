part of 'invitations_bloc.dart';

@immutable
abstract class InvitationsEvent extends Equatable {
  const InvitationsEvent();

  @override
  List<Object> get props => [];
}

class AcceptInvitation extends InvitationsEvent {
  final String notificationId;
  final String email;
  final String entityId;
  final InviteType inviteType;
  const AcceptInvitation(
      {required this.notificationId,
      required this.email,
      required this.entityId,
      required this.inviteType});

  @override
  List<Object> get props => [email, entityId, inviteType];
}

class RejectInvitation extends InvitationsEvent {
  final String notificationId;

  final String email;
  final String entityId;
  final InviteType inviteType;
  const RejectInvitation(
      {required this.notificationId,
      required this.email,
      required this.entityId,
      required this.inviteType});

  @override
  List<Object> get props => [email, entityId, inviteType];
}

class MaybeInvitation extends InvitationsEvent {
  final String notificationId;

  final String email;
  final String entityId;
  final InviteType inviteType;
  const MaybeInvitation(
      {required this.notificationId,
      required this.email,
      required this.entityId,
      required this.inviteType});

  @override
  List<Object> get props => [email, entityId, inviteType];
}
