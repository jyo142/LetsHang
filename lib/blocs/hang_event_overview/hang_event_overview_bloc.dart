import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/event_invite.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
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
      emit(await _mapLoadHangEventsToState(email: event.userEmail));
    });
    on<LoadHangEventsForDates>((event, emit) async {
      emit(await _mapLoadHangEventsToState(
          email: event.userEmail,
          startDateTime: event.startDateTime,
          endDateTime: event.endDateTime));
    });
    on<LoadIndividualEvent>((event, emit) async {
      emit(IndividualEventLoading());
      HangEvent? foundEvent =
          await _hangEventRepository.getEventById(event.eventId);
      if (foundEvent != null) {
        emit(IndividualEventRetrieved(hangEvent: foundEvent));
      } else {
        emit(const IndividualEventRetrievedError(
            errorMessage: "Unable to find event"));
      }
    });
  }

  Future<HangEventOverviewState> _mapLoadHangEventsToState(
      {required String email,
      DateTime? startDateTime,
      DateTime? endDateTime}) async {
    List<HangEventInvite> eventsForUser = [];
    if (startDateTime == null && endDateTime == null) {
      eventsForUser =
          await _userInvitesRepository.getAllUserEventInvites(email);
    } else {
      eventsForUser = await _userInvitesRepository.getUserEventInvitesByRange(
          email, startDateTime!, endDateTime!);
    }

    return HangEventsRetrieved(hangEvents: eventsForUser);
  }
}
