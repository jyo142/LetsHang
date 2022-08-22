import 'dart:collection';

import 'package:letshang/models/event_invite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';

class InvitesRepository extends BaseInvitesRepository {
  final FirebaseFirestore _firebaseFirestore;

  InvitesRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HangEventInvite>> getEventInvites(String userName) async {
    DocumentSnapshot eventInviteSnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(userName)
        .collection("eventInvites")
        .doc("events")
        .get();

    List<HangEventInvite> eventInvites = [];
    if (eventInviteSnapshot.exists) {
      eventInvites = List.of(eventInviteSnapshot["eventInvites"])
          .map((m) => HangEventInvite.fromMap(m))
          .toList();
    }
    return eventInvites;
  }

  @override
  Future<void> addEventUserInvites(
      HangEvent hangEvent, List<UserInvite> userInvites) async {
    try {
      await _firebaseFirestore.runTransaction((transaction) async {
        DocumentReference dbUserInvitesRef = _firebaseFirestore
            .collection('hangEvents')
            .doc(hangEvent.id)
            .collection('invites')
            .doc("userInvites");

        if (userInvites.isNotEmpty) {
          await addUserInvites(hangEvent, userInvites, transaction);
        }

        transaction.set(dbUserInvitesRef, {
          "userInvites":
              hangEvent.userInvites.map((ui) => ui.toDocument()).toList()
        });
      });
    } catch (e) {
      var hello = 2;
    }
  }

  @override
  Future<void> editEventUserInvites(HangEvent hangEvent) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbUserInvitesRef = _firebaseFirestore
          .collection('hangEvents')
          .doc(hangEvent.id)
          .collection('invites')
          .doc("userInvites");
      DocumentSnapshot dbUserInvitesSnap =
          await transaction.get(dbUserInvitesRef);
      List<UserInvite> dbUserInvites = List.of(dbUserInvitesSnap["userInvites"])
          .map((m) => UserInvite.fromMap(m))
          .toList();

      List<UserInvite> toAdd =
          findUserInvitesDifferences(dbUserInvites, hangEvent.userInvites);
      if (toAdd.isNotEmpty) {
        await addUserInvites(hangEvent, toAdd, transaction);
      }

      List<UserInvite> toRemove =
          findUserInvitesDifferences(hangEvent.userInvites, dbUserInvites);

      if (toRemove.isNotEmpty) {
        await removeUserInvites(hangEvent, toRemove, transaction);
      }
      transaction.update(dbUserInvitesRef, {
        "userInvites":
            hangEvent.userInvites.map((ui) => ui.toDocument()).toList()
      });
    });
  }

  Future<void> addUserInvites(
      HangEvent event, List<UserInvite> toAdd, Transaction transaction) async {
    await Future.wait(toAdd.map((ui) async {
      DocumentReference eventInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("eventInvites")
          .doc("events");
      final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

      HangEventInvite newEventInvite =
          HangEventInvite(event: event, status: ui.status, type: ui.type);

      List<HangEventInvite> retValEvents = [];
      if (eventInviteDocumentSnap.exists) {
        retValEvents = eventInviteDocumentSnap.get("eventInvites");
        retValEvents.add(newEventInvite);
      } else {
        retValEvents.add(newEventInvite);
      }
      transaction.update(eventInviteRef,
          {"eventInvites": List.of(retValEvents.map((e) => e.toDocument()))});
    }));
  }

  Future<void> removeUserInvites(HangEvent event, List<UserInvite> toRemove,
      Transaction transaction) async {
    await Future.wait(toRemove.map((ui) async {
      DocumentReference eventInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("eventInvites")
          .doc("events");
      final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

      List<HangEventInvite> retValEvents = [];
      if (eventInviteDocumentSnap.exists) {
        retValEvents = eventInviteDocumentSnap.get("eventInvites");
        retValEvents = retValEvents
            .where((element) => element.event.id != event.id)
            .toList();
      }
      transaction.update(eventInviteRef,
          {"eventInvites": List.of(retValEvents.map((e) => e.toDocument()))});
    }));
  }

  /// finds user invites that are in the second user invites and not in the
  /// first user invites
  List<UserInvite> findUserInvitesDifferences(
      List<UserInvite> firstUserInvites, List<UserInvite> secondUserInvites) {
    HashSet<String> firstUserInviteSet =
        HashSet.from(firstUserInvites.map((e) => e.user.userName));
    return secondUserInvites
        .where((element) => !firstUserInviteSet.contains(element.user.userName))
        .toList();
  }
}
