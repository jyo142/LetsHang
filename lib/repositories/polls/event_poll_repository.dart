import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:letshang/models/events/hang_event_poll_result.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/polls/base_event_poll_repository.dart';

class EventPollRepository extends BaseEventPollRepository {
  final FirebaseFirestore _firebaseFirestore;

  EventPollRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HangEventPoll>> getActiveEventPolls(String eventId) async {
    List<HangEventPoll> activePolls = await getEventPolls(eventId, true);
    return activePolls;
  }

  Future<List<HangEventPoll>> getEventPolls(
      String eventId, bool isActive) async {
    QuerySnapshot snapshots = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .where("completedDate", isNull: isActive)
        .get();

    final allEventPollSnapshots =
        snapshots.docs.map((doc) => doc.data()).toList();
    List<HangEventPoll> eventPolls = allEventPollSnapshots
        .map((doc) => HangEventPoll.fromMap(doc as Map<String, dynamic>))
        .toList();
    return eventPolls;
  }

  @override
  Future<HangEventPoll> addEventPoll(
      String eventId, HangEventPoll newPoll) async {
    CollectionReference hangEventPollRef = _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls");
    HangEventPoll savingPoll =
        HangEventPoll.withId(hangEventPollRef.doc().id, newPoll);

    // get the event snapshot for the event preview on the responsibility
    DocumentSnapshot currentHangEventSnapshot =
        await _firebaseFirestore.collection('hangEvents').doc(eventId).get();
    HangEvent currentHangEvent =
        HangEvent.fromSnapshot(currentHangEventSnapshot);
    savingPoll = savingPoll.copyWith(
        event: HangEventPreview.fromEvent(currentHangEvent));

    // save to db
    await hangEventPollRef.doc(savingPoll.id).set(savingPoll.toDocument());
    return savingPoll;
  }

  @override
  Future<List<HangEventPollResult>> getIndividualPollResults(
      String eventId, String eventPollId) async {
    QuerySnapshot hangEventPollResultsSnapshots = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .doc(eventPollId)
        .collection("results")
        .get();
    final allEventPollResultsSnapshots =
        hangEventPollResultsSnapshots.docs.map((doc) => doc.data()).toList();
    List<HangEventPollResult> eventPollResults = allEventPollResultsSnapshots
        .map((doc) => HangEventPollResult.fromMap(doc as Map<String, dynamic>))
        .toList();
    return eventPollResults;
  }

  @override
  Future<HangEventPollResult> addPollResult(
      String eventId, HangEventPollResult pollResult) async {
    CollectionReference hangEventPollResultRef = _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .doc(pollResult.pollId)
        .collection("results");

    HangEventPollResult savingPollResult =
        HangEventPollResult.withId(hangEventPollResultRef.doc().id, pollResult);
    await hangEventPollResultRef
        .doc(savingPollResult.id)
        .set(savingPollResult.toDocument());

    return savingPollResult;
  }

  @override
  Future<void> removePollResult(
      String eventId, String pollId, String pollResultId) async {
    await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .doc(pollId)
        .collection("results")
        .doc(pollResultId)
        .delete();
  }
}
