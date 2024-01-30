import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/events/hang_event_poll.dart';
import 'package:letshang/models/events/hang_event_poll_result.dart';
import 'package:letshang/models/events/user_hang_event_poll.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/repositories/polls/base_event_poll_repository.dart';

class EventPollRepository extends BaseEventPollRepository {
  final FirebaseFirestore _firebaseFirestore;

  EventPollRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<HangEventPoll?> getIndividualPoll(
      String eventId, String eventPollId) async {
    DocumentSnapshot eventPollSnapshot = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .doc(eventPollId)
        .get();
    if (eventPollSnapshot.exists) {
      return HangEventPoll.fromSnapshot(eventPollSnapshot);
    }
    return null;
  }

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
  Future<List<HangEventPollWithResultCount>> getActiveEventPollsWithResultCount(
      String eventId, String userId) async {
    List<HangEventPoll> activePolls = await getEventPolls(eventId, true);

    List<HangEventPollWithResultCount> results =
        await Future.wait(activePolls.map((e) async {
      final pollResultCount = await getResultCountForPoll(eventId, e.id!);
      final hasUserCompleted =
          await hasUserCompletedPoll(eventId, e.id!, userId);
      return HangEventPollWithResultCount(
          eventPoll: e,
          resultCount: pollResultCount,
          userCompleted: hasUserCompleted);
    }));

    return results;
  }

  Future<int> getResultCountForPoll(String eventId, String pollId) async {
    AggregateQuerySnapshot pollResultCountQuery = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .doc(pollId)
        .collection("results")
        .count()
        .get();

    return pollResultCountQuery.count;
  }

  Future<bool> hasUserCompletedPoll(
      String eventId, String pollId, String userId) async {
    AggregateQuerySnapshot pollResultCountQuery = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .doc(pollId)
        .collection("results")
        .where("pollUser.userId", isEqualTo: userId)
        .count()
        .get();

    return pollResultCountQuery.count != 0;
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

    CollectionReference userEventPollRef = _firebaseFirestore
        .collection('users')
        .doc(savingPoll.creatingUser.userId)
        .collection("eventPolls")
        .doc(eventId)
        .collection("polls");
    // add a user event poll to notify user that they need to fill out the poll
    await addUpdateUserEventPoll(userEventPollRef,
        savingPoll.creatingUser.userId, savingPoll.id!, false);

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

    CollectionReference userEventPollRef = _firebaseFirestore
        .collection('users')
        .doc(savingPollResult.pollUser.userId)
        .collection("eventPolls")
        .doc(eventId)
        .collection("polls");
    // after adding the poll result make sure to add a user poll to indicate that the user filled out the poll
    await addUpdateUserEventPoll(userEventPollRef,
        savingPollResult.pollUser.userId, savingPollResult.pollId, true);
    return savingPollResult;
  }

  Future<void> addUpdateUserEventPoll(CollectionReference userEventPollRef,
      String userId, String pollId, bool isCompleted) async {
    QuerySnapshot userEventPollQuerySnap =
        await userEventPollRef.where("pollId", isEqualTo: pollId).get();

    if (userEventPollQuerySnap.size == 0) {
      UserHangEventPoll newUserHangEventPoll = UserHangEventPoll(
          id: userEventPollRef.doc().id,
          userId: userId,
          pollId: pollId,
          completedDate: isCompleted ? DateTime.now() : null);
      userEventPollRef
          .doc(newUserHangEventPoll.id)
          .set(newUserHangEventPoll.toDocument());
    } else {
      Map<String, dynamic> userEventPollMap =
          userEventPollQuerySnap.docs[0].data() as Map<String, dynamic>;
      UserHangEventPoll curUserEventPoll =
          UserHangEventPoll.fromMap(userEventPollMap);
      curUserEventPoll = isCompleted
          ? curUserEventPoll.copyWith(completedDate: DateTime.now())
          : curUserEventPoll.resetCompletionDate();
      userEventPollRef
          .doc(curUserEventPoll.id)
          .set(curUserEventPoll.toDocument());
    }
  }

  @override
  Future<void> removePollResult(
      String eventId, String userId, String pollId, String pollResultId) async {
    await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("polls")
        .doc(pollId)
        .collection("results")
        .doc(pollResultId)
        .delete();

    // update the user event poll collection to reset the completed date
    CollectionReference userEventPollRef = _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection("eventPolls")
        .doc(eventId)
        .collection("polls");
    await addUpdateUserEventPoll(userEventPollRef, userId, pollId, false);
  }

  @override
  Future<int> getNonCompletedUserPollCount(
      String eventId, String userId) async {
    AggregateQuerySnapshot hangEventPollResultsSnapshots =
        await _firebaseFirestore
            .collection('users')
            .doc(userId)
            .collection("eventPolls")
            .doc(eventId)
            .collection("polls")
            .where("completedDate", isNull: true)
            .count()
            .get();
    return hangEventPollResultsSnapshots.count;
  }
}
