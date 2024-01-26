import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:letshang/models/events/user_hang_event_responsibility.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/repositories/responsibilities/base_responsibilities_repository.dart';

class ResponsibilitiesRepository extends BaseResponsibilitiesRepository {
  final FirebaseFirestore _firebaseFirestore;

  ResponsibilitiesRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HangEventResponsibility>> getActiveEventResponsibilities(
      String eventId) async {
    List<HangEventResponsibility> activeResponsibilities =
        await getEventResponsibilities(eventId, true);
    return activeResponsibilities;
  }

  @override
  Future<List<HangEventResponsibility>> getCompletedEventResponsibilities(
      String eventId) async {
    List<HangEventResponsibility> activeResponsibilities =
        await getEventResponsibilities(eventId, false);
    return activeResponsibilities;
  }

  Future<List<HangEventResponsibility>> getEventResponsibilities(
      String eventId, bool isActive) async {
    QuerySnapshot snapshots = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("responsibilities")
        .where("completedDate", isNull: isActive)
        .get();

    final allEventResponsibilitiesSnapshots =
        snapshots.docs.map((doc) => doc.data()).toList();
    List<HangEventResponsibility> eventResponsibilities =
        allEventResponsibilitiesSnapshots
            .map((doc) =>
                HangEventResponsibility.fromMap(doc as Map<String, dynamic>))
            .toList();
    return eventResponsibilities;
  }

  @override
  Future<List<HangEventResponsibility>> getUserResponsibilitiesForEvent(
      String eventId, String userId) async {
    QuerySnapshot snapshots = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("responsibilities")
        .where("assignedUser.userId", isEqualTo: userId)
        .get();
    final allEventResponsibilitiesSnapshots =
        snapshots.docs.map((doc) => doc.data()).toList();
    List<HangEventResponsibility> eventResponsibilities =
        allEventResponsibilitiesSnapshots
            .map((doc) =>
                HangEventResponsibility.fromMap(doc as Map<String, dynamic>))
            .toList();
    return eventResponsibilities;
  }

  @override
  Future<HangEventResponsibility> addEventResponsibility(
      String eventId, HangEventResponsibility newResponsibility) async {
    CollectionReference hangEventResponsibilityRef = _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("responsibilities");
    HangEventResponsibility savingResponsibility =
        HangEventResponsibility.withId(
            hangEventResponsibilityRef.doc().id, newResponsibility);

    // get the event snapshot for the event preview on the responsibility
    DocumentSnapshot currentHangEventSnapshot =
        await _firebaseFirestore.collection('hangEvents').doc(eventId).get();
    HangEvent currentHangEvent =
        HangEvent.fromSnapshot(currentHangEventSnapshot);
    savingResponsibility = savingResponsibility.copyWith(
        event: HangEventPreview.fromEvent(currentHangEvent));

    // save to db
    await hangEventResponsibilityRef
        .doc(savingResponsibility.id)
        .set(savingResponsibility.toDocument());

    // add user responsibility for the assigned user
    CollectionReference userEventResponsibilityRef = _firebaseFirestore
        .collection('users')
        .doc(savingResponsibility.assignedUser.userId)
        .collection("eventResponsibilities")
        .doc(eventId)
        .collection("responsibilities");
    await addUpdateUserEventResponsibility(
        userEventResponsibilityRef,
        savingResponsibility.assignedUser.userId,
        savingResponsibility.id!,
        false);
    return savingResponsibility;
  }

  Future<void> addUpdateUserEventResponsibility(
      CollectionReference userEventResponsibilityRef,
      String userId,
      String responsibilityId,
      bool isCompleted) async {
    QuerySnapshot userEventResponsibilityQuerySnap =
        await userEventResponsibilityRef
            .where("eventResponsibilityId", isEqualTo: responsibilityId)
            .get();

    if (userEventResponsibilityQuerySnap.size == 0) {
      UserHangEventResponsibility newUserHangEventResponsibility =
          UserHangEventResponsibility(
              id: userEventResponsibilityRef.doc().id,
              userId: userId,
              eventResponsibilityId: responsibilityId,
              completedDate: isCompleted ? DateTime.now() : null);
      userEventResponsibilityRef
          .doc(newUserHangEventResponsibility.id)
          .set(newUserHangEventResponsibility.toDocument());
    } else {
      Map<String, dynamic> userEventResponsibilityMap =
          userEventResponsibilityQuerySnap.docs[0].data()
              as Map<String, dynamic>;
      UserHangEventResponsibility curUserEventResponsibility =
          UserHangEventResponsibility.fromMap(userEventResponsibilityMap);
      curUserEventResponsibility =
          curUserEventResponsibility.copyWith(completedDate: DateTime.now());
      userEventResponsibilityRef
          .doc(curUserEventResponsibility.id)
          .set(curUserEventResponsibility);
    }
  }

  @override
  Future<void> completeEventResponsibility(
      String eventId, HangEventResponsibility toComplete) async {
    CollectionReference hangEventResponsibilityRef = _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("responsibilities");

    HangEventResponsibility withCompletedDate =
        toComplete.copyWith(completedDate: DateTime.now());

    // save to db
    await hangEventResponsibilityRef
        .doc(withCompletedDate.id)
        .set(withCompletedDate.toDocument());

    // update the user responsibility to completed
    CollectionReference userEventResponsibiliyRef = _firebaseFirestore
        .collection('users')
        .doc(toComplete.assignedUser.userId)
        .collection("eventResponsibilities")
        .doc(eventId)
        .collection("responsibilities");
    await addUpdateUserEventResponsibility(userEventResponsibiliyRef,
        toComplete.assignedUser.userId, toComplete.id!, true);
  }

  @override
  Future<int> getNonCompletedUserResponsibilityCount(
      String eventId, String userId) async {
    AggregateQuerySnapshot hangEventResponsibilityResultsSnapshots =
        await _firebaseFirestore
            .collection('users')
            .doc(userId)
            .collection("eventResponsibilities")
            .doc(eventId)
            .collection("responsibilities")
            .where("completedDate", isNull: true)
            .count()
            .get();
    return hangEventResponsibilityResultsSnapshots.count;
  }
}
