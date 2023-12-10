part of 'participants_bloc.dart';

@immutable
class ParticipantsState extends Equatable {
  final AddParticipantBy addParticipantBy;
  final String searchByUsernameValue;
  final String searchByEmailValue;
  final String searchByGroupValue;

  List<UserInvite> attendingUsers;
  List<UserInvite> invitedUsers;
  List<UserInvite> rejectedUsers;
  late final Set<String> allUsers;

  ParticipantsState({
    this.addParticipantBy = AddParticipantBy.none,
    this.searchByUsernameValue = '',
    this.searchByEmailValue = '',
    this.searchByGroupValue = '',
    List<UserInvite>? attendingUsers,
    List<UserInvite>? invitedUsers,
    List<UserInvite>? rejectedUsers,
  })  : attendingUsers = attendingUsers ?? const [],
        invitedUsers = invitedUsers ?? const [],
        rejectedUsers = rejectedUsers ?? const [],
        allUsers = Set.of((attendingUsers ?? const [])
            .map((e) => e.user.email!)
            .followedBy((invitedUsers ?? const []).map((e) => e.user.email!))
            .followedBy(
                (rejectedUsers ?? const []).map((e) => e.user.email!))) {
    List<UserInvite> sortedAttendingUsers = List.from(this.attendingUsers);
    sortedAttendingUsers.sort((a, b) {
      int? titleComparison = a.title != null && b.title != null
          ? a.title!.index.compareTo(b.title!.index)
          : null;
      if (titleComparison == null || titleComparison == 0) {
        return a.user.name!.compareTo(b.user!.name!);
      }
      return titleComparison;
    });

    List<UserInvite> sortedInvitedUsers = List.from(this.invitedUsers);
    sortedInvitedUsers.sort((a, b) => a.user.name!.compareTo(b.user!.name!));

    List<UserInvite> sortedRejectedUsers = List.from(this.rejectedUsers);
    sortedRejectedUsers.sort((a, b) => a.user.name!.compareTo(b.user!.name!));

    // Assign the sorted lists back to the fields
    this.attendingUsers = sortedAttendingUsers;
    this.invitedUsers = sortedInvitedUsers;
    this.rejectedUsers = sortedRejectedUsers;
  }

  ParticipantsState.fromState(ParticipantsState state)
      : this(
            addParticipantBy: state.addParticipantBy,
            searchByUsernameValue: state.searchByUsernameValue,
            searchByEmailValue: state.searchByEmailValue,
            searchByGroupValue: state.searchByGroupValue,
            attendingUsers: state.attendingUsers,
            invitedUsers: state.invitedUsers,
            rejectedUsers: state.rejectedUsers);

  ParticipantsState copyWith(
      {AddParticipantBy? addParticipantBy,
      String? searchByUsernameValue,
      String? searchByEmailValue,
      String? searchByGroupValue,
      List<UserInvite>? attendingUsers,
      List<UserInvite>? invitedUsers,
      List<UserInvite>? rejectedUsers}) {
    return ParticipantsState(
        addParticipantBy: addParticipantBy ?? this.addParticipantBy,
        searchByUsernameValue:
            searchByUsernameValue ?? this.searchByUsernameValue,
        searchByEmailValue: searchByEmailValue ?? this.searchByEmailValue,
        searchByGroupValue: searchByGroupValue ?? this.searchByGroupValue,
        attendingUsers: attendingUsers ?? this.attendingUsers,
        invitedUsers: invitedUsers ?? this.invitedUsers,
        rejectedUsers: rejectedUsers ?? this.rejectedUsers);
  }

  ParticipantsState addInvitee(
      HangUserPreview newInvitee, InviteType type, InviteTitle? title,
      [InviteStatus status = InviteStatus.pending]) {
    UserInvite newUserInvitee =
        UserInvite(user: newInvitee, status: status, type: type, title: title);
    final newInvitees = List.of(invitedUsers);
    newInvitees.add(newUserInvitee);
    allUsers.add(newUserInvitee.user.email!);
    return copyWith(invitedUsers: newInvitees);
  }

  ParticipantsState removeInvitee(HangUserPreview newInvitee) {
    UserInvite newUserInvitee = UserInvite(
        user: newInvitee, status: InviteStatus.pending, type: InviteType.event);
    final newInvitees = List.of(invitedUsers);
    newInvitees
        .removeWhere((element) => element.user.email == newInvitee.email);
    allUsers.remove(newUserInvitee.user.email!);
    return copyWith(invitedUsers: newInvitees);
  }

  ParticipantsState promoteInvitee(HangUserPreview toPromoteUser) {
    final newInvitees = List.of(invitedUsers);

    final indexOfUserInvite = newInvitees
        .indexWhere((element) => element.user.email == toPromoteUser.email);
    UserInvite foundUserInvite = newInvitees[indexOfUserInvite];
    newInvitees[indexOfUserInvite] = UserInvite(
        user: foundUserInvite.user,
        status: foundUserInvite.status,
        type: foundUserInvite.type,
        title: InviteTitle.admin,
        invitingUser: foundUserInvite.invitingUser);

    return copyWith(invitedUsers: newInvitees);
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

class HangEventParticipantsLoading extends ParticipantsState {}

class SearchParticipantLoading extends ParticipantsState {
  SearchParticipantLoading(ParticipantsState state) : super.fromState(state);
}

class SearchParticipantRetrieved extends ParticipantsState {
  final HangUser? foundUser;
  final bool? hasEventConflict;
  SearchParticipantRetrieved(ParticipantsState state,
      {this.foundUser, this.hasEventConflict})
      : super.fromState(state);

  @override
  List<Object?> get props => [foundUser, hasEventConflict];
}

class SearchParticipantError extends ParticipantsState {
  final String errorMessage;
  SearchParticipantError(ParticipantsState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}

class SendInviteLoading extends ParticipantsState {
  SendInviteLoading(ParticipantsState state) : super.fromState(state);
}

class SendInviteSuccess extends ParticipantsState {
  SendInviteSuccess(ParticipantsState state) : super.fromState(state);
}

class SendAllInvitesLoading extends ParticipantsState {
  SendAllInvitesLoading(ParticipantsState state) : super.fromState(state);
}

class SendAllInvitesError extends ParticipantsState {
  final String errorMessage;
  SendAllInvitesError(ParticipantsState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}

class SendAllInvitesSuccess extends ParticipantsState {
  SendAllInvitesSuccess(ParticipantsState state) : super.fromState(state);
}

class SendInviteError extends ParticipantsState {
  final String errorMessage;
  SendInviteError(ParticipantsState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}

class SearchGroupLoading extends ParticipantsState {
  SearchGroupLoading(ParticipantsState state) : super.fromState(state);
}

class SearchGroupRetrieved extends ParticipantsState {
  final Group foundGroup;
  SearchGroupRetrieved(ParticipantsState state, {required this.foundGroup})
      : super.fromState(state);

  @override
  List<Object> get props => [foundGroup];
}

class SearchGroupError extends ParticipantsState {
  final String errorMessage;
  SearchGroupError(ParticipantsState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object?> get props => [errorMessage];
}

class SelectMembersState extends ParticipantsState {
  final List<UserInvite> allMembers;
  late final Map<String, UserInvite> selectedMembers;
  SelectMembersState(
    ParticipantsState state, {
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
      ParticipantsState state, UserInvite newSelectedMember) {
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
