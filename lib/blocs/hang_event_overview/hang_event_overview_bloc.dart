import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'hang_event_overview_event.dart';
part 'hang_event_overview_state.dart';

class HangEventOverviewBloc
    extends Bloc<HangEventOverviewEvent, HangEventOverviewState> {
  final HangEventRepository _hangEventRepository;
  StreamSubscription? _hangEventSubscription;

  // constructor
  HangEventOverviewBloc({required HangEventRepository hangEventRepository})
      : _hangEventRepository = hangEventRepository,
        super(HangEventsLoading());

  @override
  Stream<HangEventOverviewState> mapEventToState(
      HangEventOverviewEvent event) async* {
    if (event is LoadHangEvents) {
      yield* _mapLoadHangEventsToState();
    }
    if (event is UpdateHangEvents) {
      yield* _mapUpdateHangEventsToState(event);
    }
  }

  Stream<HangEventOverviewState> _mapLoadHangEventsToState() async* {
    _hangEventSubscription?.cancel();
    _hangEventSubscription =
        _hangEventRepository.getAllEvents().listen((hangEvent) {
      add(UpdateHangEvents(hangEvent));
    });
  }

  Stream<HangEventOverviewState> _mapUpdateHangEventsToState(
      UpdateHangEvents event) async* {
    yield HangEventsRetrieved(hangEvents: event.hangEvents);
  }
}
