import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/discussions/discussion_message.dart';
import 'package:letshang/models/discussions/discussion_metadata.dart';
import 'package:letshang/models/discussions/discussion_model.dart';
import 'package:letshang/models/discussions/event_discussions_model.dart';
import 'package:letshang/models/discussions/user_discussions_model.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_preview.dart';
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
  Future<List<DiscussionModel>> getEventDiscussions(String eventId) async {
    QuerySnapshot snapshots = await _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("discussions")
        .get();

    final allEventDiscussionsSnapshots =
        snapshots.docs.map((doc) => doc.data()).toList();
    List<DiscussionModel> eventDiscussions = allEventDiscussionsSnapshots
        .map((doc) => DiscussionModel.fromMap(doc as Map<String, dynamic>))
        .toList();
    return eventDiscussions;
  }

  @override
  Future<void> addEventDiscussion(
    HangEventPreview event,
    bool isMainDiscussion,
    List<HangUserPreview> discussionMembers,
  ) async {
    final collectionRef = _firebaseFirestore
        .collection('hangEvents')
        .doc(event.eventId)
        .collection("discussions");

    // create the discussion (collection of messages)
    DiscussionMetadataModel metadataModel =
        await createDiscussion(discussionMembers);

    DiscussionModel retValDiscussionModel = DiscussionModel(
        id: collectionRef.doc().id,
        discussionId: metadataModel.id!,
        isMainDiscussion: isMainDiscussion,
        discussionMembers: discussionMembers,
        event: event);

    await collectionRef
        .doc(retValDiscussionModel.id)
        .set(retValDiscussionModel.toDocument());
  }

  @override
  Future<void> addUsersToEventMainDiscussion(
      String eventId, List<HangUserPreview> allNewUsers) async {
    final collectionReference = _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("discussions");

    QuerySnapshot mainDiscussionQuerySnap = await collectionReference
        .where('isMainDiscussion', isEqualTo: true)
        .get();

    Map<String, dynamic>? discussionModelMap =
        mainDiscussionQuerySnap.docs.isNotEmpty
            ? mainDiscussionQuerySnap.docs.first.data()! as Map<String, dynamic>
            : null;
    addUsersToDiscussion(collectionReference, discussionModelMap, allNewUsers);
  }

  @override
  Future<void> addUserToEventMainDiscussion(
      String eventId, HangUserPreview newUser) async {
    final collectionReference = _firebaseFirestore
        .collection('hangEvents')
        .doc(eventId)
        .collection("discussions");

    QuerySnapshot mainDiscussionQuerySnap = await collectionReference
        .where('isMainDiscussion', isEqualTo: true)
        .get();

    Map<String, dynamic>? discussionModelMap =
        mainDiscussionQuerySnap.docs.isNotEmpty
            ? mainDiscussionQuerySnap.docs.first.data()! as Map<String, dynamic>
            : null;
    addUsersToDiscussion(collectionReference, discussionModelMap, [newUser]);
  }

  Future<void> addUsersToDiscussion(
      CollectionReference collectionReference,
      Map<String, dynamic>? discussionModelMap,
      List<HangUserPreview> allUsersToAdd) async {
    DiscussionModel mainDiscussion;
    if (discussionModelMap == null) {
      // no main discussion need to create one.
      DiscussionMetadataModel metadataModel =
          await createDiscussion(allUsersToAdd);
      mainDiscussion = DiscussionModel(
          id: collectionReference.doc().id,
          discussionId: metadataModel.id!,
          isMainDiscussion: true,
          discussionMembers: allUsersToAdd);
    } else {
      mainDiscussion = DiscussionModel.fromMap(discussionModelMap);
      mainDiscussion.discussionMembers.addAll(allUsersToAdd);
    }

    await collectionReference
        .doc(mainDiscussion.id)
        .set(mainDiscussion.toDocument());
  }

  Future<DiscussionMetadataModel> createDiscussion(
      List<HangUserPreview> discussionMembers) async {
    DiscussionMetadataModel savingMetadataModel = DiscussionMetadataModel(
        id: FirebaseFirestore.instance.collection('discussions').doc().id,
        discussionMembers: discussionMembers);

    await _firebaseFirestore
        .collection('discussions')
        .doc(savingMetadataModel.id)
        .set(savingMetadataModel.toDocument());

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

  @override
  Future<List<UserDiscussionsModel>> getUserDiscussions(String userId) async {
    final userDiscussionsSnapshots = await _firebaseFirestore
        .collection('userDiscussions')
        .doc(userId)
        .collection("discussions")
        .get();

    final userDiscussionDocSnapshots =
        userDiscussionsSnapshots.docs.map((doc) => doc.data()).toList();
    List<UserDiscussionsModel> userDiscussions =
        await Future.wait(userDiscussionDocSnapshots.map((doc) async {
      UserDiscussionsModel userDiscussionsModel =
          UserDiscussionsModel.fromMap(doc as Map<String, dynamic>);
      DiscussionMessage? lastMessage =
          await getDiscussionLastMessage(userDiscussionsModel);
      if (lastMessage != null) {
        userDiscussionsModel = userDiscussionsModel.copyWithUserDiscussion(
            lastMessage: lastMessage);
      }
      return userDiscussionsModel;
    }));

    return userDiscussions;
  }

  Future<DiscussionMessage?> getDiscussionLastMessage(
      DiscussionModel discussion) async {
    final lastMessageQuerySnapshot = await _firebaseFirestore
        .collection('discussions')
        .doc(discussion.discussionId)
        .collection('messages')
        .orderBy('creationDate', descending: true)
        .limit(1)
        .get();
    if (lastMessageQuerySnapshot.docs.isNotEmpty) {
      DocumentSnapshot lastMessageSnapshot =
          lastMessageQuerySnapshot.docs.first;
      DiscussionMessage lastMessage =
          DiscussionMessage.fromSnapshot(lastMessageSnapshot);
      return lastMessage;
    }
    return null;
  }

  Future<List<DiscussionModel>> getDiscussionsWithLastMessage(
      List<DiscussionModel> allDiscussions) async {
    List<DiscussionModel> discussionsWithLastMessage =
        await Future.wait(allDiscussions.map((e) async {
      DiscussionMessage? lastMessage = await getDiscussionLastMessage(e);
      if (lastMessage != null) {
        e.copyWith(lastMessage: lastMessage);
      }
      return e;
    }).toList());
    return discussionsWithLastMessage;
  }
}
