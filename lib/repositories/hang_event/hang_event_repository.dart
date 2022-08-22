import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/hang_event/base_hang_event_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HangEventRepository extends BaseHangEventRepository {
  final FirebaseFirestore _firebaseFirestore;

  HangEventRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

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
  Future<List<HangEvent>> getEventsForUser(String userName) async {
    QuerySnapshot querySnapshots = await _firebaseFirestore
        .collection('hangEvents')
        .where('eventInviteeIds', arrayContains: userName)
        .get();

    return querySnapshots.docs
        .map((doc) => HangEvent.fromSnapshot(doc))
        .toList();
  }

  @override
  Future<HangEvent> addHangEvent(HangEvent hangEvent) async {
    DocumentReference docRef = await _firebaseFirestore
        .collection('hangEvents')
        .add(hangEvent.toDocument());
    return HangEvent.withId(docRef.id, hangEvent);
  }

  @override
  Future<HangEvent> editHangEvent(HangEvent hangEvent) async {
    await _firebaseFirestore
        .collection('hangEvents')
        .doc(hangEvent.id)
        .set(hangEvent.toDocument());
    return hangEvent;
  }
}
