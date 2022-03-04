import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

class EventsState {
  final String eventName;
  final String eventDescription;
  final DateTime eventDate;

  EventsState(
      {this.eventName = '', this.eventDescription = '', DateTime? eventDate})
      : this.eventDate = eventDate ?? DateTime.now();

  EventsState copyWith({
    String? eventName,
    String? eventDescription,
    DateTime? eventDate,
  }) {
    return EventsState(
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventDate: eventDate ?? this.eventDate,
    );
  }
}
