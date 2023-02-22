part of 'hang_event_participants_bloc.dart';

@immutable
class HangEventParticipantsState extends Equatable {
  final AddParticipantBy addParticipantBy;
  final String searchByUsernameValue;
  final String searchByEmailValue;
  final String searchByGroupValue;

  final List<UserInvite> attendingUsers;
  final List<UserInvite> invitedUsers;
  final List<UserInvite> rejectedUsers;
  late final Set<String> allUsers;

  HangEventParticipantsState(
      {this.addParticipantBy = AddParticipantBy.none,
      this.searchByUsernameValue = '',
      this.searchByEmailValue = '',
      this.searchByGroupValue = '',
      this.attendingUsers = const [],
      this.invitedUsers = const [],
      this.rejectedUsers = const []}) {
    allUsers = Set.of(attendingUsers.map((e) => e.user.email!));
    allUsers.addAll(invitedUsers.map((e) => e.user.email!));
    allUsers.addAll(rejectedUsers.map((e) => e.user.email!));
  }

  HangEventParticipantsState.fromState(HangEventParticipantsState state)
      : this(
            addParticipantBy: state.addParticipantBy,
            searchByUsernameValue: state.searchByUsernameValue,
            searchByEmailValue: state.searchByEmailValue,
            searchByGroupValue: state.searchByGroupValue,
            attendingUsers: state.attendingUsers,
            invitedUsers: state.invitedUsers,
            rejectedUsers: state.rejectedUsers);

  HangEventParticipantsState copyWith(
      {AddParticipantBy? addParticipantBy,
      String? searchByUsernameValue,
      String? searchByEmailValue,
      String? searchByGroupValue,
      List<UserInvite>? attendingUsers,
      List<UserInvite>? invitedUsers,
      List<UserInvite>? rejectedUsers}) {
    return HangEventParticipantsState(
        addParticipantBy: addParticipantBy ?? this.addParticipantBy,
        searchByUsernameValue:
            searchByUsernameValue ?? this.searchByUsernameValue,
        searchByEmailValue: searchByEmailValue ?? this.searchByEmailValue,
        searchByGroupValue: searchByGroupValue ?? this.searchByGroupValue,
        attendingUsers: attendingUsers ?? this.attendingUsers,
        invitedUsers: invitedUsers ?? this.invitedUsers,
        rejectedUsers: rejectedUsers ?? this.rejectedUsers);
  }

  @override
  List<Object?> get props => [
        addParticipantBy,
        searchByUsernameValue,
        searchByEmailValue,
        searchByGroupValue,
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

class SearchParticipantError extends HangEventParticipantsState {
  final String errorMessage;
  SearchParticipantError(HangEventParticipantsState state,
      {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}

class SendInviteLoading extends HangEventParticipantsState {
  SendInviteLoading(HangEventParticipantsState state) : super.fromState(state);
}

class SendInviteSuccess extends HangEventParticipantsState {
  SendInviteSuccess(HangEventParticipantsState state) : super.fromState(state);
}

class SendInviteError extends HangEventParticipantsState {
  final String errorMessage;
  SendInviteError(HangEventParticipantsState state,
      {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}

class SearchGroupLoading extends HangEventParticipantsState {
  SearchGroupLoading(HangEventParticipantsState state) : super.fromState(state);
}

class SearchGroupRetrieved extends HangEventParticipantsState {
  final Group foundGroup;
  SearchGroupRetrieved(HangEventParticipantsState state,
      {required this.foundGroup})
      : super.fromState(state);

  @override
  List<Object> get props => [foundGroup];
}

class SearchGroupError extends HangEventParticipantsState {
  final String errorMessage;
  SearchGroupError(HangEventParticipantsState state,
      {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}

class SelectMembersState extends HangEventParticipantsState {
  final List<UserInvite> allMembers;
  late final Map<String, UserInvite> selectedMembers;
  SelectMembersState(
    HangEventParticipantsState state, {
    required this.allMembers,
    Map<String, UserInvite>? selectedMembers,
  }) : super.fromState(state) {
    this.selectedMembers = selectedMembers ?? {};
  }

  SelectMembersState.fromState(SelectMembersState state)
      : this(state,
            allMembers: state.allMembers,
            selectedMembers: state.selectedMembers);

  SelectMembersState toggleSelectedMember(
      HangEventParticipantsState state, UserInvite newSelectedMember) {
    final newSelectedMembers = Map.of(selectedMembers);

    if (!newSelectedMembers.containsKey(newSelectedMember.user.email)) {
      newSelectedMembers.putIfAbsent(
          newSelectedMember.user.email!, () => newSelectedMember);
    } else {
      newSelectedMembers.remove(newSelectedMember.user.email);
    }
    return copySelectMembersStateWith(state,
        selectedMembers: newSelectedMembers);
  }

  SelectMembersState copySelectMembersStateWith(state,
      {List<UserInvite>? allMembers,
      Map<String, UserInvite>? selectedMembers}) {
    return SelectMembersState(state,
        allMembers: allMembers ?? this.allMembers,
        selectedMembers: selectedMembers ?? this.selectedMembers);
  }

  @override
  List<Object?> get props => [allMembers, selectedMembers];
}

class SelectMembersInviteLoading extends SelectMembersState {
  SelectMembersInviteLoading(SelectMembersState state) : super.fromState(state);
}

class SelectMembersInviteError extends SelectMembersState {
  final String errorMessage;
  SelectMembersInviteError(SelectMembersState state,
      {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}
