import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/repositories/responsibilities/base_responsibilities_repository.dart';

class ResponsibilitiesRepository extends BaseResponsibilitiesRepository {
  final FirebaseFirestore _firebaseFirestore;

  ResponsibilitiesRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HangEventResponsibility>> getEventResponsibilities(
      String eventId) async {
    QuerySnapshot snapshots = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("responsibilities")
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
    HangEventResponsibility savingResponsibility =
        HangEventResponsibility.withId(
            FirebaseFirestore.instance.collection('hangEvents').doc().id,
            newResponsibility);

    // get the event snapshot for the event preview on the responsibility
    DocumentSnapshot currentHangEventSnapshot =
        await _firebaseFirestore.collection('hangEvents').doc(eventId).get();
    HangEvent currentHangEvent =
        HangEvent.fromSnapshot(currentHangEventSnapshot);
    savingResponsibility = savingResponsibility.copyWith(event: HangEventPreview.fromEvent(currentHangEvent));

    // save to db
    await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("responsibilities")
        .add(savingResponsibility.toDocument());
    return savingResponsibility;
  }
}
