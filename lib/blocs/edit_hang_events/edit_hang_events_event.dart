import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_event_model.dart';

abstract class EditHangEventsEvent extends Equatable {
  const EditHangEventsEvent();

  @override
  List<Object> get props => [];
}

class EventNameChanged extends EditHangEventsEvent {
  const EventNameChanged(this.eventName);

  final String eventName;

  @override
  List<Object> get props => [eventName];
}

class EventDescriptionChanged extends EditHangEventsEvent {
  const EventDescriptionChanged(this.eventDescription);

  final String eventDescription;

  @override
  List<Object> get props => [eventDescription];
}

class EventDateChanged extends EditHangEventsEvent {
  const EventDateChanged(this.eventDate);

  final DateTime eventDate;

  @override
  List<Object> get props => [eventDate];
}

class EventSaved extends EditHangEventsEvent {
  final HangEvent event;

  const EventSaved({required this.event});

  @override
  List<Object> get props => [event];
}
