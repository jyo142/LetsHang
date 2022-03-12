class EditHangEventsState {
  final String hangEventId;
  final String eventName;
  final String eventDescription;
  final DateTime eventDate;

  EditHangEventsState(
      {this.hangEventId = '',
      this.eventName = '',
      this.eventDescription = '',
      DateTime? eventDate})
      : this.eventDate = eventDate ?? DateTime.now();

  EditHangEventsState copyWith({
    String? hangEventId,
    String? eventName,
    String? eventDescription,
    DateTime? eventDate,
  }) {
    return EditHangEventsState(
      hangEventId: hangEventId ?? this.hangEventId,
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventDate: eventDate ?? this.eventDate,
    );
  }
}
