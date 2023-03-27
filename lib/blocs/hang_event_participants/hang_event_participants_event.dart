part of 'hang_event_participants_bloc.dart';

@immutable
class HangEventParticipantsEvent extends Equatable {
  const HangEventParticipantsEvent();

  @override
  List<Object> get props => [];
}

class LoadHangEventParticipants extends HangEventParticipantsEvent {}

class AddPeoplePressed extends HangEventParticipantsEvent {}

class SearchByEmailPressed extends HangEventParticipantsEvent {}

class SearchByUsernamePressed extends HangEventParticipantsEvent {}

class SearchByUsernameChanged extends HangEventParticipantsEvent {
  const SearchByUsernameChanged({required this.usernameValue});

  final String usernameValue;

  @override
  List<Object> get props => [usernameValue];
}

class SearchByEmailChanged extends HangEventParticipantsEvent {
  const SearchByEmailChanged({required this.emailValue});

  final String emailValue;

  @override
  List<Object> get props => [emailValue];
}

class SearchByUsernameSubmitted extends HangEventParticipantsEvent {}

class SearchByEmailSubmitted extends HangEventParticipantsEvent {}

class ClearSearchFields extends HangEventParticipantsEvent {}

class GoBackSearch extends HangEventParticipantsEvent {}

class SendInviteInitiated extends HangEventParticipantsEvent {
  const SendInviteInitiated({required this.invitedUser});
  final HangUser invitedUser;

  @override
  List<Object> get props => [invitedUser];
}

class AddInviteeInitiated extends HangEventParticipantsEvent {
  const AddInviteeInitiated({required this.invitedUser});
  final HangUser invitedUser;

  @override
  List<Object> get props => [invitedUser];
}

class SendAllInviteesInitiated extends HangEventParticipantsEvent {}

class SearchByGroupChanged extends HangEventParticipantsEvent {
  const SearchByGroupChanged({required this.groupValue});

  final String groupValue;

  @override
  List<Object> get props => [groupValue];
}

class SearchByGroupSubmitted extends HangEventParticipantsEvent {}

class SelectMembersInitiated extends HangEventParticipantsEvent {
  const SelectMembersInitiated(
      {required this.eventMembers, required this.groupMembers});

  final Set<String> eventMembers;
  final List<UserInvite> groupMembers;

  @override
  List<Object> get props => [eventMembers, groupMembers];
}

class SelectMembersSelected extends HangEventParticipantsEvent {
  const SelectMembersSelected(
      {required this.groupMembers, required this.selectedMember});
  final List<UserInvite> groupMembers;

  final UserInvite selectedMember;

  @override
  List<Object> get props => [groupMembers, selectedMember];
}

class SelectMembersInviteInitiated extends HangEventParticipantsEvent {
  const SelectMembersInviteInitiated({required this.selectedMembers});
  final Map<String, UserInvite> selectedMembers;

  @override
  List<Object> get props => [selectedMembers];
}
