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
        super(const HangEventOverviewState(
            hangEventOverviewStateStatus:
                HangEventOverviewStateStatus.loading)) {
    on<LoadHangEvents>((event, emit) async {
      emit(await _mapLoadHangEventsToState(userId: event.userId));
    });
    on<LoadUpcomingEvents>((event, emit) async {
      emit(state.copyWith(
          hangEventOverviewStateStatus: HangEventOverviewStateStatus.loading));
      emit(await _mapLoadUpcomingDraftHangEventsToState(userId: event.userId));
    });
    on<LoadPastEvents>((event, emit) async {
      emit(state.copyWith(
          hangEventOverviewStateStatus: HangEventOverviewStateStatus.loading));
      emit(await _mapLoadPastHangEventsToState(userId: event.userId));
    });
    on<UpdateHangEventsTab>((event, emit) async {
      emit(state.copyWith(hangEventsScreenTab: event.screenTab));
    });
    on<LoadHangEventsForDates>((event, emit) async {
      emit(await _mapLoadHangEventsToState(
          userId: event.userId,
          startDateTime: event.startDateTime,
          endDateTime: event.endDateTime));
    });
    on<LoadIndividualEvent>((event, emit) async {
      emit(state.copyWith(
          hangEventOverviewStateStatus: HangEventOverviewStateStatus.loading));
      HangEvent? foundEvent =
          await _hangEventRepository.getEventById(event.eventId);
      if (foundEvent != null) {
        List<UserInvite> acceptedInvites = await _userInvitesRepository
            .getEventAcceptedUserInvites(event.eventId);
        foundEvent = foundEvent.copyWith(userInvites: acceptedInvites);
        emit(state.copyWith(
            hangEventOverviewStateStatus:
                HangEventOverviewStateStatus.individualEventRetrieved,
            individualHangEvent: foundEvent));
      } else {
        emit(state.copyWith(
            hangEventOverviewStateStatus: HangEventOverviewStateStatus.error,
            errorMessage: "Unable to find event"));
      }
    });
  }

  Future<HangEventOverviewState> _mapLoadUpcomingDraftHangEventsToState(
      {required String userId}) async {
    UpcomingDraftEventInvites upcomingDraftEventInvites =
        await _userInvitesRepository.getUpcomingDraftEventInvites(userId);

    List<HangEventInvite> eventsForUser = [
      ...upcomingDraftEventInvites.draftEventInvites,
      ...HangEventInviteUtils.sortEventInvitesByDraftUpcoming(
          upcomingDraftEventInvites.upcomingEventInvites),
    ];
    return state.copyWith(
        hangEventOverviewStateStatus:
            HangEventOverviewStateStatus.hangEventsRetrieved,
        draftUpcomingHangEvents: eventsForUser);
  }

  Future<HangEventOverviewState> _mapLoadPastHangEventsToState(
      {required String userId}) async {
    List<HangEventInvite> eventsForUser =
        await _userInvitesRepository.getPastEventInvites(userId);
    return state.copyWith(
        hangEventOverviewStateStatus:
            HangEventOverviewStateStatus.hangEventsRetrieved,
        pastHangEvents: eventsForUser);
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
      List<HangEventInvite> rangeUpcomingEventInvites =
          await _userInvitesRepository.getUserEventInvitesByRange(
              userId, startDateTime!, endDateTime!);
      eventsForUser = rangeUpcomingEventInvites;
    }
    Map<String, List<HangEventInvite>> dateToEvents = {
      for (HangEventInvite item in eventsForUser)
        DateFormat('MM/dd/yyyy').format(item.event.eventStartDateTime!): [item]
    };
    return state.copyWith(
        dateToEvents: dateToEvents,
        hangEventOverviewStateStatus:
            HangEventOverviewStateStatus.hangEventsRetrieved,
        hangEvents: eventsForUser);
  }
}
