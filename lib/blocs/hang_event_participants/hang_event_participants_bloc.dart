import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_participants.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'hang_event_participants_event.dart';
part 'hang_event_participants_state.dart';

class HangEventParticipantsBloc
    extends Bloc<HangEventParticipantsEvent, HangEventParticipantsState> {
  final HangEventRepository _hangEventRepository;
  final UserRepository _userRepository;
  final String hangEventId;
  // constructor
  HangEventParticipantsBloc({required this.hangEventId})
      : _hangEventRepository = HangEventRepository(),
        _userRepository = UserRepository(),
        super(HangEventParticipantsLoading());

  @override
  Stream<HangEventParticipantsState> mapEventToState(
      HangEventParticipantsEvent event) async* {
    if (event is LoadHangEventParticipants) {
      yield* _mapLoadHangEventsToState();
    }
    if (event is AddPeoplePressed) {
      yield state.copyWith(addParticipantBy: AddParticipantBy.none);
    }
    if (event is SearchByEmailPressed) {
      yield state.copyWith(addParticipantBy: AddParticipantBy.email);
    }
    if (event is SearchByUsernamePressed) {
      yield state.copyWith(addParticipantBy: AddParticipantBy.username);
    }
    if (event is SearchByUsernameChanged) {
      yield state.copyWith(searchByUsernameValue: event.usernameValue);
    }
    if (event is SearchByEmailChanged) {
      yield state.copyWith(searchByEmailValue: event.emailValue);
    }
    if (event is SearchByUsernameSubmitted) {
      yield SearchParticipantLoading(state);
      yield* _mapSearchParticipantsState();
    }
  }

  Stream<HangEventParticipantsState> _mapLoadHangEventsToState() async* {
    List<UserInvite> allUserInvites =
        await _hangEventRepository.getUserInvitesForEvent(hangEventId);

    List<UserInvite> attendingUsers = allUserInvites
        .where((element) => element.status == InviteStatus.accepted)
        .toList();

    List<UserInvite> invitedUsers = allUserInvites
        .where((element) => element.status == InviteStatus.pending)
        .toList();

    List<UserInvite> rejectedUsers = allUserInvites
        .where((element) => element.status == InviteStatus.rejected)
        .toList();
    yield state.copyWith(
        attendingUsers: attendingUsers,
        invitedUsers: invitedUsers,
        rejectedUsers: rejectedUsers);
  }

  Stream<HangEventParticipantsState> _mapSearchParticipantsState() async* {
    HangUser? retValUser;
    if (state.addParticipantBy == AddParticipantBy.username) {
      retValUser =
          await _userRepository.getUserByUserName(state.searchByUsernameValue);
    }
    if (state.addParticipantBy == AddParticipantBy.email) {
      retValUser =
          await _userRepository.getUserByEmail(state.searchByEmailValue);
    }
    yield SearchParticipantRetrieved(state, foundUser: retValUser);
  }
}
