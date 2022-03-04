import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object> get props => [];
}

class EventNameChanged extends EventsEvent {
  const EventNameChanged(this.eventName);

  final String eventName;

  @override
  List<Object> get props => [eventName];
}

class EventDescriptionChanged extends EventsEvent {
  const EventDescriptionChanged(this.eventDescription);

  final String eventDescription;

  @override
  List<Object> get props => [eventDescription];
}

class EventDateChanged extends EventsEvent {
  const EventDateChanged(this.eventDate);

  final DateTime eventDate;

  @override
  List<Object> get props => [eventDate];
}

class EventSaved extends EventsEvent {
  @override
  List<Object> get props => [];
}
