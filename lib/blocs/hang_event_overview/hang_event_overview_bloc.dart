import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

part 'hang_event_overview_event.dart';
part 'hang_event_overview_state.dart';

class HangEventOverviewBloc
    extends Bloc<HangEventOverviewEvent, HangEventOverviewState> {
  final BaseUserInvitesRepository _userInvitesRepository;
  final String email;
  // constructor
  HangEventOverviewBloc({required this.email})
      : _userInvitesRepository = UserInvitesRepository(),
        super(HangEventsLoading());

  @override
  Stream<HangEventOverviewState> mapEventToState(
      HangEventOverviewEvent event) async* {
    if (event is LoadHangEvents) {
      yield* _mapLoadHangEventsToState();
    }
    if (event is LoadHangEventsForDates) {
      yield* _mapLoadHangEventsToState(
          startDateTime: event.startDateTime, endDateTime: event.endDateTime);
    }
  }

  Stream<HangEventOverviewState> _mapLoadHangEventsToState(
      {DateTime? startDateTime, DateTime? endDateTime}) async* {
    List<HangEventInvite> eventsForUser = [];
    if (startDateTime == null && endDateTime == null) {
      eventsForUser =
          await _userInvitesRepository.getAllUserEventInvites(email);
    } else {
      eventsForUser = await _userInvitesRepository.getUserEventInvitesByRange(
          email, startDateTime!, endDateTime!);
    }

    yield HangEventsRetrieved(hangEvents: eventsForUser);
  }
}
