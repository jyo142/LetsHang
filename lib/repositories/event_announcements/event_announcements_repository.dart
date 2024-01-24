import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/events/hang_event_announcement.dart';
import 'package:letshang/repositories/event_announcements/base_event_announcements_repository.dart';

class EventAnnouncementsRepository extends BaseEventAnnouncementsRepository {
  final FirebaseFirestore _firebaseFirestore;

  EventAnnouncementsRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HangEventAnnouncement>> getEventAnnoucements(
      String eventId) async {
    QuerySnapshot snapshots = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("announcements")
        .orderBy("creationDate", descending: true)
        .get();

    final allEventAnnouncementSnapshots =
        snapshots.docs.map((doc) => doc.data()).toList();
    List<HangEventAnnouncement> eventAnnouncements =
        allEventAnnouncementSnapshots
            .map((doc) =>
                HangEventAnnouncement.fromMap(doc as Map<String, dynamic>))
            .toList();
    return eventAnnouncements;
  }

  @override
  Future<HangEventAnnouncement> addEventAnnouncement(
      String eventId, HangEventAnnouncement newAnnouncement) async {
    CollectionReference hangEventAnnouncementsRef = _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("announcements");
    HangEventAnnouncement savingAnnouncement = HangEventAnnouncement.withId(
        hangEventAnnouncementsRef.doc().id, newAnnouncement);

    // get the event snapshot for the event preview on the responsibility
    // save to db
    await hangEventAnnouncementsRef
        .doc(savingAnnouncement.id)
        .set(savingAnnouncement.toDocument());
    return savingAnnouncement;
  }
}
