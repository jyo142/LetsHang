import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HangEvent extends Equatable {
  final String id;
  final String eventName;
  final String eventDescription;
  late final DateTime eventStartDate;
  late final DateTime eventEndDate;

  HangEvent(
      {this.id = '',
      this.eventName = '',
      this.eventDescription = '',
      DateTime? eventStartDate,
      DateTime? eventEndDate}) {
    this.eventStartDate = eventStartDate ?? DateTime.now();
    this.eventEndDate = eventEndDate ?? DateTime.now();
  }

  static HangEvent fromSnapshot(DocumentSnapshot snap) {
    Timestamp startDateTimestamp = snap['startDateTime'];
    Timestamp endDateTimestamp = snap['endDateTime'];
    HangEvent event = HangEvent(
        id: snap.id,
        eventName: snap['name'],
        eventDescription: snap['description'],
        eventStartDate: startDateTimestamp.toDate(),
        eventEndDate: endDateTimestamp.toDate());
    return event;
  }

  Map<String, Object> toDocument() {
    return {
      'name': eventName,
      'description': eventDescription,
      'startDateTime': Timestamp.fromDate(eventStartDate),
      'endDateTime': Timestamp.fromDate(eventEndDate)
    };
  }

  @override
  List<Object> get props =>
      [id, eventName, eventDescription, eventStartDate, eventEndDate];
}
