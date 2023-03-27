import 'dart:collection';

import 'package:letshang/models/event_invite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';

class UserInvitesRepository extends BaseUserInvitesRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserInvitesRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<HangEventInvite>> getUserEventInvites(String email) async {
    DocumentSnapshot eventInviteSnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(email)
        .collection("eventInvites")
        .doc("events")
        .get();

    List<HangEventInvite> eventInvites = [];
    if (eventInviteSnapshot.exists) {
      eventInvites = List.of(eventInviteSnapshot["eventInvites"])
          .map((m) => HangEventInvite.fromMap(m))
          .toList();
    }

    List<HangEventInvite> retValInvites = [];
    for (HangEventInvite curEventInvite in eventInvites) {
      DocumentReference eventReference = _firebaseFirestore
          .collection("hangEvents")
          .doc(curEventInvite.event.id);

      // need a reference to the event to get the main event details
      DocumentSnapshot eventSnapshot = await eventReference.get();
      // we need to get all the userInvites for the event to get the event invite previews
      DocumentSnapshot eventInviteSnapshot =
          await eventReference.collection("invites").doc("userInvites").get();
      List<UserInvite> allEventUserInvites =
          List.of(eventInviteSnapshot["userInvites"])
              .map((m) => UserInvite.fromMap(m))
              .toList();
      HangEvent curEvent = HangEvent.fromSnapshot(eventSnapshot);
      HangEvent newEvent = curEvent.copyWith(userInvites: allEventUserInvites);
      retValInvites.add(HangEventInvite(
          event: newEvent,
          status: curEventInvite.status,
          type: curEventInvite.type));
    }
    return retValInvites;
  }

  @override
  Future<void> addUserEventInvites(
      HangEvent hangEvent, List<UserInvite> userInvites) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbEventsUserInvitesRef = _firebaseFirestore
          .collection('hangEvents')
          .doc(hangEvent.id)
          .collection('invites')
          .doc("userInvites");

      // before adding users to the event, make sure that there are no duplicates
      final eventsUserInvitesSnap =
          await transaction.get(dbEventsUserInvitesRef);
      if (!eventsUserInvitesSnap.exists) {
        throw Exception(
            "Unable to add users to event. Event cannot be retrieved.");
      }
      List<UserInvite> retValInvites =
          List.of(eventsUserInvitesSnap["userInvites"])
              .map((m) => UserInvite.fromMap(m))
              .toList();
      Map<String, UserInvite> userInviteMap = {
        for (UserInvite ui in retValInvites) ui.user.email!: ui
      };
      for (UserInvite newUserInvite in userInvites) {
        if (userInviteMap.containsKey(newUserInvite.user.email)) {
          throw Exception("User is already invited to this event");
        }
        retValInvites.add(newUserInvite);
      }

      // for each user, add a userinvite for them
      await Future.wait(userInvites.map((ui) async {
        await addUserInvite(hangEvent, ui, transaction);
      }));
      transaction.set(dbEventsUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> addUserEventInvite(
      HangEvent hangEvent, UserInvite userInvite) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbEventsUserInvitesRef = _firebaseFirestore
          .collection('hangEvents')
          .doc(hangEvent.id)
          .collection('invites')
          .doc("userInvites");

      final eventsUserInvitesSnap =
          await transaction.get(dbEventsUserInvitesRef);

      // check if the user is already part of the invites and add if not
      if (!eventsUserInvitesSnap.exists) {
        throw Exception(
            "Unable to add users to event. Event cannot be retrieved.");
      }

      List<UserInvite> retValInvites =
          List.of(eventsUserInvitesSnap["userInvites"])
              .map((m) => UserInvite.fromMap(m))
              .toList();
      Map<String, UserInvite> userInviteMap = {
        for (UserInvite ui in retValInvites) ui.user.email!: ui
      };
      if (userInviteMap.containsKey(userInvite.user.email)) {
        throw Exception("User is already invited to this event");
      }

      retValInvites.add(userInvite);

      await addUserInvite(hangEvent, userInvite, transaction);

      transaction.set(dbEventsUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> editUserEventInvites(HangEvent hangEvent) async {
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

  Future<void> addUserInvite(
      HangEvent hangEvent, UserInvite toAdd, Transaction transaction) async {
    DocumentReference eventInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toAdd.user.email)
        .collection("eventInvites")
        .doc("events");
    final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

    HangEventInvite newEventInvite = HangEventInvite(
        event: hangEvent, status: toAdd.status, type: toAdd.type);

    List<HangEventInvite> retValEvents = [];
    if (eventInviteDocumentSnap.exists) {
      retValEvents = List.of(eventInviteDocumentSnap["eventInvites"])
          .map((m) => HangEventInvite.fromMap(m))
          .toList();

      Map<String, HangEventInvite> hangEventInviteMap = {
        for (HangEventInvite hei in retValEvents) hei.event.id: hei
      };
      if (hangEventInviteMap.containsKey(newEventInvite.event.id)) {
        throw Exception("User is already invited to this event");
      }
    }
    retValEvents.add(newEventInvite);

    transaction.set(eventInviteRef,
        {"eventInvites": retValEvents.map((e) => e.toDocument()).toList()});
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
        retValEvents = List.of(eventInviteDocumentSnap.get("eventInvites"));
        retValEvents.add(newEventInvite);
      } else {
        retValEvents.add(newEventInvite);
      }
      transaction.set(eventInviteRef,
          {"eventInvites": retValEvents.map((e) => e.toDocument()).toList()});
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
        retValEvents = List.of(eventInviteDocumentSnap.get("eventInvites"));
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
