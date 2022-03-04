import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/events/events_event.dart';
import 'package:letshang/blocs/events/events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsState());

  @override
  Stream<EventsState> mapEventToState(EventsEvent event) async* {
    if (event is EventNameChanged) {
      yield state.copyWith(eventName: event.eventName);
    } else if (event is EventDescriptionChanged) {
      yield state.copyWith(eventDescription: event.eventDescription);
    } else if (event is EventDateChanged) {
      yield state.copyWith(eventDate: event.eventDate);
    } else {
      yield state;
    }
  }
}
