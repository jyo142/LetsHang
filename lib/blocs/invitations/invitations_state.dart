part of 'invitations_bloc.dart';

enum InvitationsStateStatus {
  initial,
  invitationStatusChangedLoading,
  invitationStatusChangedSuccess,
  pendingInvitationsLoading,
  pendingInvitationsRetrieved,
  error
}

@immutable
class InvitationsState extends Equatable {
  final PendingInvites? allPendingInvites;
  final String? errorMessage;
  final InvitationsStateStatus invitationsStateStatus;
  final String? invitationStatusChangedSuccessMessage;
  const InvitationsState(
      {this.allPendingInvites,
      required this.invitationsStateStatus,
      this.errorMessage,
      this.invitationStatusChangedSuccessMessage});

  InvitationsState copyWith({
    PendingInvites? allPendingInvites,
    InvitationsStateStatus? invitationsStateStatus,
    String? invitationStatusChangedSuccessMessage,
    String? errorMessage,
  }) {
    return InvitationsState(
        allPendingInvites: allPendingInvites ?? this.allPendingInvites,
        invitationsStateStatus:
            invitationsStateStatus ?? this.invitationsStateStatus,
        invitationStatusChangedSuccessMessage:
            invitationStatusChangedSuccessMessage ??
                this.invitationStatusChangedSuccessMessage,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        allPendingInvites,
        invitationsStateStatus,
        invitationStatusChangedSuccessMessage,
        errorMessage
      ];
}
