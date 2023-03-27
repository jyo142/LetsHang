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
  }

  Stream<HangEventOverviewState> _mapLoadHangEventsToState() async* {
    final eventsForUser =
        await _userInvitesRepository.getUserEventInvites(email);
    yield HangEventsRetrieved(hangEvents: eventsForUser);
  }
}
