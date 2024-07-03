import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/hang_event/base_hang_event_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HangEventRepository extends BaseHangEventRepository {
  final FirebaseFirestore _firebaseFirestore;

  HangEventRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<HangEvent?> getEventById(String eventId) async {
    DocumentSnapshot docSnapshot =
        await _firebaseFirestore.collection('hangEvents').doc(eventId).get();
    if (docSnapshot.exists) {
      return HangEvent.fromSnapshot(docSnapshot);
    }
    return null;
  }

  @override
  Future<List<HangEvent>> getAllEvents() async {
    QuerySnapshot querySnapshots = await _firebaseFirestore
        .collection('hangEvents')
        .orderBy('startDateTime', descending: true)
        .get();

    return Future.wait(querySnapshots.docs
        .map((e) async => await constructHangEvent(e))
        .toList());
  }

  Future<HangEvent> constructHangEvent(QueryDocumentSnapshot docSnap) async {
    DocumentSnapshot inviteDocSnapshot = await _firebaseFirestore
        .collection('hangEvents')
        .doc(docSnap.id)
        .collection("invites")
        .doc("userInvites")
        .get();

    List<UserInvite> invites = [];
    if (inviteDocSnapshot.exists) {
      invites = List.of(inviteDocSnapshot["userInvites"])
          .map((m) => UserInvite.fromMap(m))
          .toList();
    }
    return HangEvent.fromSnapshot(docSnap, invites);
  }

  @override
  Future<HangEvent> addHangEvent(HangEvent hangEvent) async {
    HangEvent savingEvent = HangEvent.withId(
        FirebaseFirestore.instance.collection('hangEvents').doc().id,
        hangEvent);
    await _firebaseFirestore
        .collection('hangEvents')
        .doc(savingEvent.id)
        .set(savingEvent.toDocument());
    return savingEvent;
  }

  @override
  Future<HangEvent> editHangEvent(HangEvent hangEvent) async {
    await _firebaseFirestore
        .collection('hangEvents')
        .doc(hangEvent.id)
        .set(hangEvent.toDocument());
    return hangEvent;
  }

  @override
  Future<List<UserInvite>> getUserInvitesForEvent(String hangEventId) async {
    QuerySnapshot eventsUserInvitesQuerySnap = await _firebaseFirestore
        .collection('hangEvents')
        .doc(hangEventId)
        .collection('invites')
        .get();

    final allDocSnapshots =
        eventsUserInvitesQuerySnap.docs.map((doc) => doc.data()).toList();

    List<UserInvite> invites = allDocSnapshots
        .map((doc) => UserInvite.fromMap(doc as Map<String, dynamic>))
        .toList();

    return invites;
  }

  @override
  Future<void> cancelHangEvent(String hangEventId) async {
    HangEvent? curEvent = await getEventById(hangEventId);

    if (curEvent == null) {
      throw Exception("Unable to find event.");
    }
    curEvent.validateEventWrite();

    HangEvent cancelledEvent = curEvent.copyWith(isCancelled: true);
    await _firebaseFirestore
        .collection('hangEvents')
        .doc(cancelledEvent.id)
        .set(cancelledEvent.toDocument());
  }
}
