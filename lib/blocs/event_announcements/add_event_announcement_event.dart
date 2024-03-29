part of 'add_event_announcement_bloc.dart';

abstract class AddEventAnnouncementEvent extends Equatable {
  const AddEventAnnouncementEvent();

  @override
  List<Object> get props => [];
}

class AnnouncementContentChanged extends AddEventAnnouncementEvent {
  final String announcementContent;

  const AnnouncementContentChanged({required this.announcementContent});

  @override
  List<Object> get props => [announcementContent];
}

class SubmitAddAnnouncement extends AddEventAnnouncementEvent {
  final String eventId;
  final HangUserPreview creatingUser;
  const SubmitAddAnnouncement(
      {required this.eventId, required this.creatingUser});

  @override
  List<Object> get props => [eventId, creatingUser];
}
