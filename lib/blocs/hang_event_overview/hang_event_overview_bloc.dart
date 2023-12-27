import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/hang_event/base_hang_event_repository.dart';
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
  final BaseHangEventRepository _hangEventRepository;
  // constructor
  HangEventOverviewBloc()
      : _userInvitesRepository = UserInvitesRepository(),
        _hangEventRepository = HangEventRepository(),
        super(HangEventsLoading()) {
    on<LoadHangEvents>((event, emit) async {
      emit(await _mapLoadHangEventsToState(userId: event.userId));
    });
    on<LoadUpcomingEvents>((event, emit) async {
      emit(await _mapLoadUpcomingDraftHangEventsToState(userId: event.userId));
    });
    on<LoadPastEvents>((event, emit) async {
      emit(await _mapLoadPastHangEventsToState(userId: event.userId));
    });
    on<LoadHangEventsForDates>((event, emit) async {
      emit(await _mapLoadHangEventsToState(
          userId: event.userId,
          startDateTime: event.startDateTime,
          endDateTime: event.endDateTime));
    });
    on<LoadIndividualEvent>((event, emit) async {
      emit(IndividualEventLoading());
      HangEvent? foundEvent =
          await _hangEventRepository.getEventById(event.eventId);
      if (foundEvent != null) {
        List<UserInvite> acceptedInvites = await _userInvitesRepository
            .getEventAcceptedUserInvites(event.eventId);
        foundEvent = foundEvent.copyWith(userInvites: acceptedInvites);
        emit(IndividualEventRetrieved(hangEvent: foundEvent));
      } else {
        emit(const IndividualEventRetrievedError(
            errorMessage: "Unable to find event"));
      }
    });
  }

  Future<HangEventOverviewState> _mapLoadUpcomingDraftHangEventsToState(
      {required String userId}) async {
    List<HangEventInvite> eventsForUser =
        await _userInvitesRepository.getUpcomingDraftEventInvites(userId);

    return HangEventsRetrieved(hangEvents: eventsForUser);
  }

  Future<HangEventOverviewState> _mapLoadPastHangEventsToState(
      {required String userId}) async {
    List<HangEventInvite> eventsForUser =
        await _userInvitesRepository.getPastEventInvites(userId);

    return HangEventsRetrieved(hangEvents: eventsForUser);
  }

  Future<HangEventOverviewState> _mapLoadHangEventsToState(
      {required String userId,
      DateTime? startDateTime,
      DateTime? endDateTime}) async {
    List<HangEventInvite> eventsForUser = [];
    if (startDateTime == null && endDateTime == null) {
      eventsForUser =
          await _userInvitesRepository.getAllUserEventInvites(userId);
    } else {
      eventsForUser = await _userInvitesRepository.getUserEventInvitesByRange(
          userId, startDateTime!, endDateTime!);
    }

    return HangEventsRetrieved(hangEvents: eventsForUser);
  }
}
