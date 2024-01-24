part of 'hang_event_announcements_bloc.dart';

abstract class HangEventAnnouncementsEvent extends Equatable {
  const HangEventAnnouncementsEvent();

  @override
  List<Object> get props => [];
}

class LoadEventAnnouncements extends HangEventAnnouncementsEvent {
  final String eventId;

  const LoadEventAnnouncements({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
