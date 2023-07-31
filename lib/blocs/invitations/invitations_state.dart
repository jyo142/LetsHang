part of 'invitations_bloc.dart';

@immutable
class InvitationsState extends Equatable {
  const InvitationsState();

  @override
  List<Object> get props => [];
}

class InvitationStatusChangedLoading extends InvitationsState {}

class InvitationStatusChangedError extends InvitationsState {
  final String errorMessage;

  const InvitationStatusChangedError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class InvitationStatusChangedSuccess extends InvitationsState {
  final String successMessage;

  const InvitationStatusChangedSuccess({required this.successMessage});

  @override
  List<Object> get props => [successMessage];
}
