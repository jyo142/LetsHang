import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';

class EditHangEventsBloc
    extends Bloc<EditHangEventsEvent, EditHangEventsState> {
  final HangEventRepository _hangEventRepository;
  StreamSubscription? _hangEventSubscription;
  // constructor
  EditHangEventsBloc({required HangEventRepository hangEventRepository})
      : _hangEventRepository = hangEventRepository,
        super(EditHangEventsState());

  @override
  Stream<EditHangEventsState> mapEventToState(
      EditHangEventsEvent event) async* {
    if (event is EventNameChanged) {
      yield state.copyWith(eventName: event.eventName);
    } else if (event is EventDescriptionChanged) {
      yield state.copyWith(eventDescription: event.eventDescription);
    } else if (event is EventDateChanged) {
      yield state.copyWith(eventDate: event.eventDate);
    } else if (event is EventSaved) {
      yield* _mapEventSavedState(event, state);
    } else {
      yield state;
    }
  }

  Stream<EditHangEventsState> _mapEventSavedState(
      EventSaved eventSavedEvent, EditHangEventsState eventsState) async* {
    _hangEventSubscription?.cancel();
    try {
      HangEvent savingEvent = eventSavedEvent.event;
      if (savingEvent.id.isEmpty) {
        // this event is being edited if an id is present
        await _hangEventRepository.editHangEvent(eventSavedEvent.event);
      } else {
        await _hangEventRepository.addHangEvent(eventSavedEvent.event);
      }
    } catch (_) {}
  }
}
