class EditHangEventsState {
  final String hangEventId;
  final String eventName;
  final String eventDescription;
  late final DateTime eventStartDate;
  late final DateTime eventEndDate;

  EditHangEventsState(
      {this.hangEventId = '',
      this.eventName = '',
      this.eventDescription = '',
      DateTime? eventStartDate,
      DateTime? eventEndDate}) {
    final dateNow = DateTime.now();
    this.eventStartDate =
        eventStartDate ?? DateTime(dateNow.year, dateNow.month, dateNow.day);
    this.eventEndDate =
        eventEndDate ?? DateTime(dateNow.year, dateNow.month, dateNow.day);
  }

  EditHangEventsState copyWith({
    String? hangEventId,
    String? eventName,
    String? eventDescription,
    DateTime? eventStartDate,
    DateTime? eventEndDate,
  }) {
    return EditHangEventsState(
      hangEventId: hangEventId ?? this.hangEventId,
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventStartDate: eventStartDate ?? this.eventStartDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
    );
  }
}
