import 'package:letshang/models/events/hang_event_announcement.dart';

abstract class BaseEventAnnouncementsRepository {
  Future<List<HangEventAnnouncement>> getEventAnnoucements(String eventId);
  Future<HangEventAnnouncement> addEventAnnouncement(
      String eventId, HangEventAnnouncement newAnnouncement);
}
