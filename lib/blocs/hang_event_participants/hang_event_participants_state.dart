part of 'hang_event_participants_bloc.dart';

@immutable
class HangEventParticipantsState extends Equatable {
  final AddParticipantBy addParticipantBy;
  final String searchByUsernameValue;
  final String searchByEmailValue;

  final List<UserInvite> attendingUsers;
  final List<UserInvite> invitedUsers;
  final List<UserInvite> rejectedUsers;
  HangEventParticipantsState(
      {this.addParticipantBy = AddParticipantBy.none,
      this.searchByUsernameValue = '',
      this.searchByEmailValue = '',
      this.attendingUsers = const [],
      this.invitedUsers = const [],
      this.rejectedUsers = const []});

  HangEventParticipantsState.fromState(HangEventParticipantsState state)
      : this(
            addParticipantBy: state.addParticipantBy,
            searchByUsernameValue: state.searchByUsernameValue,
            searchByEmailValue: state.searchByEmailValue,
            attendingUsers: state.attendingUsers,
            invitedUsers: state.invitedUsers,
            rejectedUsers: state.rejectedUsers);

  HangEventParticipantsState copyWith(
      {AddParticipantBy? addParticipantBy,
      String? searchByUsernameValue,
      String? searchByEmailValue,
      List<UserInvite>? attendingUsers,
      List<UserInvite>? invitedUsers,
      List<UserInvite>? rejectedUsers}) {
    return HangEventParticipantsState(
        addParticipantBy: addParticipantBy ?? this.addParticipantBy,
        searchByUsernameValue:
            searchByUsernameValue ?? this.searchByUsernameValue,
        searchByEmailValue: searchByEmailValue ?? this.searchByEmailValue,
        attendingUsers: attendingUsers ?? this.attendingUsers,
        invitedUsers: invitedUsers ?? this.invitedUsers,
        rejectedUsers: rejectedUsers ?? this.rejectedUsers);
  }

  @override
  List<Object?> get props => [
        addParticipantBy,
        searchByUsernameValue,
        searchByEmailValue,
        attendingUsers,
        invitedUsers,
        rejectedUsers
      ];
}

class HangEventParticipantsLoading extends HangEventParticipantsState {}

class SearchParticipantLoading extends HangEventParticipantsState {
  SearchParticipantLoading(HangEventParticipantsState state)
      : super.fromState(state);
}

class SearchParticipantRetrieved extends HangEventParticipantsState {
  final HangUser? foundUser;
  SearchParticipantRetrieved(HangEventParticipantsState state, {this.foundUser})
      : super.fromState(state);

  @override
  List<Object?> get props => [foundUser];
}
