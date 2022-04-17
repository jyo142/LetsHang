import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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

class EventStartDateTimeChanged extends EditHangEventsEvent {
  const EventStartDateTimeChanged(this.eventStartDate, this.eventStartTime);

  final DateTime eventStartDate;
  final TimeOfDay eventStartTime;

  @override
  List<Object> get props => [eventStartDate];
}

class EventEndDateTimeChanged extends EditHangEventsEvent {
  const EventEndDateTimeChanged(this.eventEndDate, this.eventEndTime);

  final DateTime eventEndDate;
  final TimeOfDay eventEndTime;
  @override
  List<Object> get props => [eventEndDate];
}

class EventSaved extends EditHangEventsEvent {
  final HangEvent event;

  const EventSaved({required this.event});

  @override
  List<Object> get props => [event];
}
