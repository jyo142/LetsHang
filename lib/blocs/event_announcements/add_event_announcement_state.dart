part of 'add_event_announcement_bloc.dart';

enum AddEventAnnouncementStateStatus {
  initial,
  loading,
  successfullyAddedAnnouncement,
  error
}

class AddEventAnnouncementState extends Equatable {
  final AddEventAnnouncementStateStatus addEventAnnouncementStateStatus;
  final String? announcementContent;
  final String? errorMessage;

  const AddEventAnnouncementState(
      {required this.addEventAnnouncementStateStatus,
      this.announcementContent,
      this.errorMessage});

  AddEventAnnouncementState copyWith(
      {AddEventAnnouncementStateStatus? addEventAnnouncementStateStatus,
      String? announcementContent,
      String? errorMessage}) {
    return AddEventAnnouncementState(
        addEventAnnouncementStateStatus: addEventAnnouncementStateStatus ??
            this.addEventAnnouncementStateStatus,
        announcementContent: announcementContent ?? this.announcementContent,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [addEventAnnouncementStateStatus, announcementContent, errorMessage];
}
