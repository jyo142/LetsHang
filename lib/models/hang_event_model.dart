import 'package:cloud_firestore/cloud_firestore.dart';

class HangEvent {
  final String eventName;
  final String eventDescription;
  final DateTime eventDate;

  HangEvent(
      {this.eventName = '', this.eventDescription = '', DateTime? eventDate})
      : this.eventDate = eventDate ?? DateTime.now();

  static HangEvent fromSnapshot(DocumentSnapshot snap) {
    HangEvent event = HangEvent(
        eventName: snap['name'], eventDescription: snap['description']);
    return event;
  }
}
