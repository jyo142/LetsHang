import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/discussions/discussion_metadata.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/discussions/event_discussions_model.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/discussions/base_discussions_repository.dart';
import 'package:letshang/repositories/group/base_group_repository.dart';
import 'package:collection/collection.dart';

class DiscussionsRepository extends BaseDiscussionsRepository {
  final FirebaseFirestore _firebaseFirestore;

  DiscussionsRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<EventDiscussionsModel?> getEventDiscussions(String eventId) async {
    DocumentSnapshot docSnapshot = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("discussions")
        .doc("eventDiscussions")
        .get();
    if (docSnapshot.exists) {
      return EventDiscussionsModel.fromSnapshot(docSnapshot);
    }
    return null;
  }

  @override
  Future<void> addEventDiscussion(
    String eventId,
    bool isMainGroupDiscussion,
    List<HangUserPreview> discussionMembers,
  ) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      // get the document with all the event discussions
      DocumentReference docReference = _firebaseFirestore
          .collection('hangEvents')
          .doc(eventId)
          .collection("discussions")
          .doc("eventDiscussions");
      DocumentSnapshot docSnapshot = await transaction.get(docReference);

      // create the discussion (collection of messages)
      DiscussionMetadataModel metadataModel =
          await createDiscussion(discussionMembers, transaction);
      DiscussionModel retValDiscussionModel = DiscussionModel(
          discussionId: metadataModel.id!,
          isMainGroupDiscussion: isMainGroupDiscussion,
          discussionMembers: discussionMembers);
      EventDiscussionsModel eventDiscussionsModel;
      if (!docSnapshot.exists) {
        eventDiscussionsModel = EventDiscussionsModel(
            eventDiscussions: [retValDiscussionModel], eventId: eventId);
      } else {
        eventDiscussionsModel = EventDiscussionsModel.fromSnapshot(docSnapshot);
        eventDiscussionsModel.eventDiscussions.add(retValDiscussionModel);
      }
      transaction.set(docReference, eventDiscussionsModel.toDocument());
    });
  }

  @override
  Future<void> addUsersToEventGroupDiscussion(
      String eventId, List<HangUserPreview> allNewUsers) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference docReference = _firebaseFirestore
          .collection('hangEvents')
          .doc(eventId)
          .collection("discussions")
          .doc("eventDiscussions");
      DocumentSnapshot docSnapshot = await transaction.get(docReference);
      EventDiscussionsModel eventDiscussionsModel;
      if (!docSnapshot.exists) {
        eventDiscussionsModel =
            EventDiscussionsModel(eventDiscussions: [], eventId: eventId);
      } else {
        eventDiscussionsModel = EventDiscussionsModel.fromSnapshot(docSnapshot);
      }

      DiscussionModel? mainGroupDiscussion = eventDiscussionsModel
          .eventDiscussions
          .firstWhereOrNull((element) => element.isMainGroupDiscussion);

      if (mainGroupDiscussion == null) {
        DiscussionMetadataModel metadataModel =
            await createDiscussion(allNewUsers, transaction);
        mainGroupDiscussion = DiscussionModel(
            discussionId: metadataModel.id!,
            isMainGroupDiscussion: true,
            discussionMembers: allNewUsers);
        eventDiscussionsModel.eventDiscussions.add(mainGroupDiscussion);
      } else {
        for (HangUserPreview curNewUser in allNewUsers) {
          if (!mainGroupDiscussion.discussionMembers.contains(curNewUser)) {
            mainGroupDiscussion.discussionMembers.add(curNewUser);
          }
        }
      }

      eventDiscussionsModel = eventDiscussionsModel.copyWith(
          eventDiscussions: eventDiscussionsModel.eventDiscussions);
      transaction.set(docReference, eventDiscussionsModel.toDocument());
    });
  }

  @override
  Future<void> addUserToEventGroupDiscussion(
      String eventId, HangUserPreview newUser) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference docReference = _firebaseFirestore
          .collection('hangEvents')
          .doc(eventId)
          .collection("eventInvites")
          .doc("eventDiscussions");
      DocumentSnapshot docSnapshot = await transaction.get(docReference);
      EventDiscussionsModel eventDiscussionsModel;
      if (!docSnapshot.exists) {
        eventDiscussionsModel = EventDiscussionsModel(
            id: "eventDiscussions", eventDiscussions: [], eventId: eventId);
      } else {
        eventDiscussionsModel = EventDiscussionsModel.fromSnapshot(docSnapshot);
      }

      DiscussionModel? mainGroupDiscussion = eventDiscussionsModel
          .eventDiscussions
          .firstWhereOrNull((element) => element.isMainGroupDiscussion);

      if (mainGroupDiscussion == null) {
        DiscussionMetadataModel metadataModel =
            await createDiscussion([newUser], transaction);
        mainGroupDiscussion = DiscussionModel(
            discussionId: metadataModel.id!,
            isMainGroupDiscussion: true,
            discussionMembers: [newUser]);
        eventDiscussionsModel.eventDiscussions.add(mainGroupDiscussion);
      } else {
        if (!mainGroupDiscussion.discussionMembers.contains(newUser)) {
          mainGroupDiscussion.discussionMembers.add(newUser);
        }
      }

      eventDiscussionsModel = eventDiscussionsModel.copyWith(
          eventDiscussions: eventDiscussionsModel.eventDiscussions);
      transaction.set(docReference, eventDiscussionsModel.toDocument());
    });
  }

  Future<DiscussionMetadataModel> createDiscussion(
      List<HangUserPreview> discussionMembers, Transaction transaction) async {
    DiscussionMetadataModel savingMetadataModel = DiscussionMetadataModel(
        id: FirebaseFirestore.instance.collection('discussions').doc().id,
        discussionMembers: discussionMembers);

    DocumentReference discussionRef = _firebaseFirestore
        .collection('discussions')
        .doc(savingMetadataModel.id);

    transaction.set(discussionRef, savingMetadataModel.toDocument());
    return savingMetadataModel;
  }

  @override
  Stream<List<DiscussionMessage>> getMessagesForDiscussion(
      String discussionId) {
    final querySnapShotStream = _firebaseFirestore
        .collection('discussions')
        .doc(discussionId)
        .collection('messages')
        .orderBy('creationDate', descending: true)
        .snapshots();

    return querySnapShotStream.map(
      (event) =>
          event.docs.map((e) => DiscussionMessage.fromMap(e.data())).toList(),
    );
  }

  @override
  Future<void> sendMessageForDiscussion(
      String discussionId, HangUserPreview sendingUser, String message) async {
    DiscussionMessage newMessage = DiscussionMessage(
        messageContent: message,
        sendingUser: sendingUser,
        creationDate: DateTime.now());
    await _firebaseFirestore
        .collection('discussions')
        .doc(discussionId)
        .collection('messages')
        .add(newMessage.toDocument());
  }
}
