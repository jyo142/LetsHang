import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HangEvent extends Equatable {
  final String id;
  final String eventName;
  final String eventDescription;
  final DateTime eventDate;

  HangEvent(
      {this.id = '',
      this.eventName = '',
      this.eventDescription = '',
      DateTime? eventDate})
      : this.eventDate = eventDate ?? DateTime.now();

  static HangEvent fromSnapshot(DocumentSnapshot snap) {
    HangEvent event = HangEvent(
        id: snap.id,
        eventName: snap['name'],
        eventDescription: snap['description']);
    return event;
  }

  Map<String, Object> toDocument() {
    return {'name': eventName, 'description': eventDescription};
  }

  @override
  List<Object> get props => [id, eventName, eventDescription, eventDate];
}
