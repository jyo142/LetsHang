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
