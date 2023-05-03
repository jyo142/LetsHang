part of 'participants_bloc.dart';

@immutable
class ParticipantsEvent extends Equatable {
  const ParticipantsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHangEventParticipants extends ParticipantsEvent {}

class LoadGroupParticipants extends ParticipantsEvent {}

class AddPeoplePressed extends ParticipantsEvent {}

class SearchByEmailPressed extends ParticipantsEvent {}

class SearchByUsernamePressed extends ParticipantsEvent {}

class SearchByUsernameChanged extends ParticipantsEvent {
  const SearchByUsernameChanged({required this.usernameValue});

  final String usernameValue;

  @override
  List<Object> get props => [usernameValue];
}

class SearchByEmailChanged extends ParticipantsEvent {
  const SearchByEmailChanged({required this.emailValue});

  final String emailValue;

  @override
  List<Object> get props => [emailValue];
}

class SearchByUsernameSubmitted extends ParticipantsEvent {}

class SearchByEmailSubmitted extends ParticipantsEvent {}

class ClearSearchFields extends ParticipantsEvent {}

class GoBackSearch extends ParticipantsEvent {}

class SendInviteInitiated extends ParticipantsEvent {
  const SendInviteInitiated({required this.invitedUser});
  final HangUser invitedUser;

  @override
  List<Object> get props => [invitedUser];
}

class SendRemoveInviteInitiated extends ParticipantsEvent {
  const SendRemoveInviteInitiated({required this.toRemoveUser});
  final HangUserPreview toRemoveUser;

  @override
  List<Object> get props => [toRemoveUser];
}

class AddInviteeInitiated extends ParticipantsEvent {
  const AddInviteeInitiated({required this.invitedUser, this.inviteTitle});
  final HangUser invitedUser;
  final InviteTitle? inviteTitle;
  @override
  List<Object?> get props => [invitedUser, inviteTitle];
}

class RemoveInviteeInitiated extends ParticipantsEvent {
  const RemoveInviteeInitiated({required this.toRemoveUserPreview});
  final HangUserPreview toRemoveUserPreview;

  @override
  List<Object> get props => [toRemoveUserPreview];
}

class SendAllInviteesInitiated extends ParticipantsEvent {}

class SearchByGroupChanged extends ParticipantsEvent {
  const SearchByGroupChanged({required this.groupValue});

  final String groupValue;

  @override
  List<Object> get props => [groupValue];
}

class SearchByGroupSubmitted extends ParticipantsEvent {}

class SelectMembersInitiated extends ParticipantsEvent {
  const SelectMembersInitiated(
      {required this.eventMembers, required this.groupMembers});

  final Set<String> eventMembers;
  final List<UserInvite> groupMembers;

  @override
  List<Object> get props => [eventMembers, groupMembers];
}

class SelectMembersSelected extends ParticipantsEvent {
  const SelectMembersSelected(
      {required this.groupMembers, required this.selectedMember});
  final List<UserInvite> groupMembers;

  final UserInvite selectedMember;

  @override
  List<Object> get props => [groupMembers, selectedMember];
}

class SelectMembersInviteInitiated extends ParticipantsEvent {
  const SelectMembersInviteInitiated({required this.selectedMembers});
  final Map<String, UserInvite> selectedMembers;

  @override
  List<Object> get props => [selectedMembers];
}
