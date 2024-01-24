part of 'hang_event_announcements_bloc.dart';

enum HangEventAnnouncementsStateStatus {
  initial,
  loading,
  retrievedEventAnnouncements,
  error
}

class HangEventAnnouncementsState extends Equatable {
  final HangEventAnnouncementsStateStatus hangEventAnnouncementsStateStatus;
  final List<HangEventAnnouncement>? eventAnnouncements;
  final String? errorMessage;

  const HangEventAnnouncementsState(
      {required this.hangEventAnnouncementsStateStatus,
      this.eventAnnouncements,
      this.errorMessage});

  HangEventAnnouncementsState copyWith(
      {HangEventAnnouncementsStateStatus? hangEventAnnouncementsStateStatus,
      List<HangEventAnnouncement>? eventAnnouncements,
      String? errorMessage}) {
    return HangEventAnnouncementsState(
        hangEventAnnouncementsStateStatus: hangEventAnnouncementsStateStatus ??
            this.hangEventAnnouncementsStateStatus,
        eventAnnouncements: eventAnnouncements ?? this.eventAnnouncements,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        hangEventAnnouncementsStateStatus,
        eventAnnouncements,
        errorMessage,
      ];
}
