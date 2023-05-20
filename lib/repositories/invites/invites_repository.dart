import 'dart:collection';

import 'package:letshang/models/event_invite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/group_invite.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_event_metadata.dart';
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
      DocumentReference dbEventsRef =
          _firebaseFirestore.collection('hangEvents').doc(hangEvent.id);

      final eventsSnap = await transaction.get(dbEventsRef);
      if (!eventsSnap.exists) {
        throw Exception(
            "Unable to add users to event. Event cannot be retrieved.");
      }
      DocumentReference dbEventsUserInvitesRef =
          dbEventsRef.collection('invites').doc("userInvites");

      // before adding users to the event, make sure that there are no duplicates
      final eventsUserInvitesSnap =
          await transaction.get(dbEventsUserInvitesRef);

      List<UserInvite> retValInvites = [];
      if (eventsUserInvitesSnap.exists) {
        retValInvites = List.of(eventsUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }

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
        await addUserInviteForEvent(hangEvent, ui, transaction);
      }));
      transaction.set(dbEventsUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> addUserEventInvite(
      HangEvent hangEvent, UserInvite userInvite) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbEventsRef =
          _firebaseFirestore.collection('hangEvents').doc(hangEvent.id);

      final eventsSnap = await transaction.get(dbEventsRef);

      if (!eventsSnap.exists) {
        throw Exception(
            "Unable to add users to event. Event cannot be retrieved.");
      }

      DocumentReference dbEventsUserInvitesRef =
          dbEventsRef.collection('invites').doc("userInvites");

      final eventsUserInvitesSnap =
          await transaction.get(dbEventsUserInvitesRef);

      List<UserInvite> retValInvites = [];
      if (eventsUserInvitesSnap.exists) {
// check if the user is already part of the invites and add if not
        retValInvites = List.of(eventsUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }

      Map<String, UserInvite> userInviteMap = {
        for (UserInvite ui in retValInvites) ui.user.email!: ui
      };
      if (userInviteMap.containsKey(userInvite.user.email)) {
        throw Exception("User is already invited to this event");
      }

      retValInvites.add(userInvite);

      await addUserInviteForEvent(hangEvent, userInvite, transaction);

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
        await addUserInvitesForEvent(hangEvent, toAdd, transaction);
      }

      List<UserInvite> toRemove =
          findUserInvitesDifferences(hangEvent.userInvites, dbUserInvites);

      if (toRemove.isNotEmpty) {
        await removeUserInvitesForEvent(hangEvent, toRemove, transaction);
      }
      transaction.update(dbUserInvitesRef, {
        "userInvites":
            hangEvent.userInvites.map((ui) => ui.toDocument()).toList()
      });
    });
  }

  Future<void> addUserInviteForEvent(
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

  Future<void> addUserInvitesForEvent(
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

  Future<void> removeUserInviteForEvent(
      HangEvent event, UserInvite toRemove, Transaction transaction) async {
    DocumentReference eventInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toRemove.user.email)
        .collection("eventInvites")
        .doc("events");
    final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

    List<HangEventInvite> retValEvents = [];
    if (eventInviteDocumentSnap.exists) {
      retValEvents = List.of(eventInviteDocumentSnap.get("eventInvites"))
          .map((m) => HangEventInvite.fromMap(m))
          .where((element) => element.event.id != event.id)
          .toList();
    }
    transaction.update(eventInviteRef,
        {"eventInvites": List.of(retValEvents.map((e) => e.toDocument()))});
  }

  Future<void> removeUserInvitesForEvent(HangEvent event,
      List<UserInvite> toRemove, Transaction transaction) async {
    await Future.wait(toRemove.map((ui) async {
      DocumentReference eventInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("eventInvites")
          .doc("events");
      final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

      List<HangEventInvite> retValEvents = [];
      if (eventInviteDocumentSnap.exists) {
        retValEvents = List.of(eventInviteDocumentSnap.get("eventInvites"))
            .map((m) => HangEventInvite.fromMap(m))
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

  Future<void> promoteUserInviteForEvent(
      HangEvent event, UserInvite toPromote, Transaction transaction) async {
    DocumentReference eventInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toPromote.user.email)
        .collection("eventInvites")
        .doc("events");
    final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

    List<HangEventInvite> retValEvents = [];
    if (eventInviteDocumentSnap.exists) {
      retValEvents = List.of(eventInviteDocumentSnap.get("eventInvites"))
          .map((m) => HangEventInvite.fromMap(m))
          .toList();
    }
    final indexOfEventInvite =
        retValEvents.indexWhere((element) => element.event.id == event.id);
    if (indexOfEventInvite < 0) {
      throw Exception(
          "User is not part of the group. User cannot be promoted.");
    }
    HangEventInvite foundEventInvite = retValEvents[indexOfEventInvite];
    retValEvents[indexOfEventInvite] = HangEventInvite(
        event: foundEventInvite.event,
        status: foundEventInvite.status,
        type: foundEventInvite.type,
        title: InviteTitle.admin);

    transaction.update(eventInviteRef,
        {"groupInvites": List.of(retValEvents.map((e) => e.toDocument()))});
  }

  @override
  Future<void> promoteUserEventInvite(
      HangEvent hangEvent, UserInvite toPromote) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbEventsRef =
          _firebaseFirestore.collection('events').doc(hangEvent.id);

      final eventSnap = await transaction.get(dbEventsRef);
      if (!eventSnap.exists) {
        throw Exception(
            "Unable to promote user in event. Event cannot be retrieved.");
      }
      DocumentReference dbEventUserInvitesRef =
          dbEventsRef.collection('invites').doc("userInvites");

      // before promoting the user, make sure that they are part of the event
      final eventUserInvitesSnap = await transaction.get(dbEventUserInvitesRef);
      List<UserInvite> retValInvites = [];
      if (eventUserInvitesSnap.exists) {
        retValInvites = List.of(eventUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }
      final indexOfUserInvite = retValInvites
          .indexWhere((element) => element.user.email == toPromote.user.email);
      if (indexOfUserInvite < 0) {
        throw Exception(
            "User is not part of the group. User cannot be promoted.");
      }
      retValInvites[indexOfUserInvite] = UserInvite(
          user: toPromote.user,
          status: toPromote.status,
          type: toPromote.type,
          title: InviteTitle.admin);

      await promoteUserInviteForEvent(hangEvent, toPromote, transaction);
      transaction.set(dbEventUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<List<GroupInvite>> getUserGroupInvites(String email) async {
    DocumentSnapshot groupInviteSnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(email)
        .collection("groupInvites")
        .doc("groups")
        .get();

    List<GroupInvite> groupInvites = [];
    if (groupInviteSnapshot.exists) {
      groupInvites = List.of(groupInviteSnapshot["groupInvites"])
          .map((m) => GroupInvite.fromMap(m))
          .toList();
    }

    List<GroupInvite> retValInvites = [];
    for (GroupInvite curGroupInvite in groupInvites) {
      DocumentReference groupReference =
          _firebaseFirestore.collection("groups").doc(curGroupInvite.group.id);

      // need a reference to the group to get the main group details
      DocumentSnapshot groupSnapshot = await groupReference.get();
      // we need to get all the userInvites for the group to get the group invite previews
      DocumentSnapshot groupInviteSnapshot =
          await groupReference.collection("invites").doc("userInvites").get();
      List<UserInvite> allEventUserInvites =
          List.of(groupInviteSnapshot["userInvites"])
              .map((m) => UserInvite.fromMap(m))
              .toList();
      Group curGroup = Group.fromSnapshot(groupSnapshot);
      Group newGroup = curGroup.copyWith(userInvites: allEventUserInvites);
      retValInvites.add(GroupInvite(
          group: newGroup,
          status: curGroupInvite.status,
          type: curGroupInvite.type,
          title: curGroupInvite.title));
    }
    return retValInvites;
  }

  /// This method adds user invites for a group. Using the Collection userInvites
  Future<void> addUserInviteForGroup(
      Group group, UserInvite toAdd, Transaction transaction) async {
    DocumentReference groupInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toAdd.user.email)
        .collection("groupInvites")
        .doc("groups");
    final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

    GroupInvite newGroupInvite = GroupInvite(
        group: group,
        status: toAdd.status,
        type: toAdd.type,
        title: toAdd.title);

    List<GroupInvite> retValGroups = [];
    if (groupInviteDocumentSnap.exists) {
      retValGroups = List.of(groupInviteDocumentSnap["groupInvites"])
          .map((m) => GroupInvite.fromMap(m))
          .toList();

      Map<String, GroupInvite> groupInviteMap = {
        for (GroupInvite gi in retValGroups) gi.group.id: gi
      };
      if (groupInviteMap.containsKey(newGroupInvite.group.id)) {
        throw Exception("User is already invited to this group");
      }
    }
    retValGroups.add(newGroupInvite);

    transaction.set(groupInviteRef,
        {"groupInvites": retValGroups.map((e) => e.toDocument()).toList()});
  }

  Future<void> addUserInvitesForGroup(
      Group group, List<UserInvite> toAdd, Transaction transaction) async {
    await Future.wait(toAdd.map((ui) async {
      DocumentReference groupInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("groupInvites")
          .doc("groups");
      final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

      GroupInvite newEventInvite =
          GroupInvite(group: group, status: ui.status, type: ui.type);

      List<GroupInvite> retValGroups = [];
      if (groupInviteDocumentSnap.exists) {
        retValGroups = List.of(groupInviteDocumentSnap.get("groupInvites"));
        retValGroups.add(newEventInvite);
      } else {
        retValGroups.add(newEventInvite);
      }
      transaction.set(groupInviteRef,
          {"groupInvites": retValGroups.map((e) => e.toDocument()).toList()});
    }));
  }

  Future<void> removeUserInviteForGroup(
      Group group, UserInvite toRemove, Transaction transaction) async {
    DocumentReference groupInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toRemove.user.email)
        .collection("groupInvites")
        .doc("groups");
    final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

    List<GroupInvite> retValGroups = [];
    if (groupInviteDocumentSnap.exists) {
      retValGroups = List.of(groupInviteDocumentSnap.get("groupInvites"))
          .map((m) => GroupInvite.fromMap(m))
          .where((element) => element.group.id != group.id)
          .toList();
    }
    transaction.update(groupInviteRef,
        {"groupInvites": List.of(retValGroups.map((e) => e.toDocument()))});
  }

  Future<void> promoteUserInviteForGroup(
      Group group, UserInvite toPromote, Transaction transaction) async {
    DocumentReference groupInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toPromote.user.email)
        .collection("groupInvites")
        .doc("groups");
    final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

    List<GroupInvite> retValGroups = [];
    if (groupInviteDocumentSnap.exists) {
      retValGroups = List.of(groupInviteDocumentSnap.get("groupInvites"))
          .map((m) => GroupInvite.fromMap(m))
          .toList();
    }
    final indexOfGroupInvite =
        retValGroups.indexWhere((element) => element.group.id == group.id);
    if (indexOfGroupInvite < 0) {
      throw Exception(
          "User is not part of the group. User cannot be promoted.");
    }
    GroupInvite foundGroupInvite = retValGroups[indexOfGroupInvite];
    retValGroups[indexOfGroupInvite] = GroupInvite(
        group: foundGroupInvite.group,
        status: foundGroupInvite.status,
        type: foundGroupInvite.type,
        title: InviteTitle.admin);

    transaction.update(groupInviteRef,
        {"groupInvites": List.of(retValGroups.map((e) => e.toDocument()))});
  }

  Future<void> removeUserInvitesForGroup(
      Group group, List<UserInvite> toRemove, Transaction transaction) async {
    await Future.wait(toRemove.map((ui) async {
      DocumentReference groupInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("groupInvites")
          .doc("groups");
      final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

      List<GroupInvite> retValGroups = [];
      if (groupInviteDocumentSnap.exists) {
        retValGroups = List.of(groupInviteDocumentSnap.get("groupInvites"))
            .map((m) => GroupInvite.fromMap(m))
            .where((element) => element.group.id != group.id)
            .toList();
      }
      transaction.update(groupInviteRef,
          {"groupInvites": List.of(retValGroups.map((e) => e.toDocument()))});
    }));
  }

  /// This method adds user invites for a group to the collection "groups"
  @override
  Future<void> addUserGroupInvite(Group group, UserInvite userInvite) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbGroupRef =
          _firebaseFirestore.collection('groups').doc(group.id);

      final groupSnap = await transaction.get(dbGroupRef);
      if (!groupSnap.exists) {
        throw Exception(
            "Unable to add users to group. Group cannot be retrieved.");
      }

      DocumentReference dbGroupUserInvitesRef =
          dbGroupRef.collection('invites').doc("userInvites");

      final groupUserInvitesSnap = await transaction.get(dbGroupUserInvitesRef);
      List<UserInvite> retValInvites = [];
      if (groupUserInvitesSnap.exists) {
        retValInvites = List.of(groupUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }

      // check if the user is already part of the invites and add if not
      Map<String, UserInvite> userInviteMap = {
        for (UserInvite ui in retValInvites) ui.user.email!: ui
      };
      if (userInviteMap.containsKey(userInvite.user.email)) {
        throw Exception("User is already invited to this group");
      }

      retValInvites.add(userInvite);

      await addUserInviteForGroup(group, userInvite, transaction);

      transaction.set(dbGroupUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> addUserGroupInvites(
      Group group, List<UserInvite> userInvites) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbGroupRef =
          _firebaseFirestore.collection('groups').doc(group.id);

      final groupSnap = await transaction.get(dbGroupRef);
      if (!groupSnap.exists) {
        throw Exception(
            "Unable to add users to group. Group cannot be retrieved.");
      }
      DocumentReference dbGroupUserInvitesRef =
          dbGroupRef.collection('invites').doc("userInvites");

      // before adding users to the event, make sure that there are no duplicates
      final groupUserInvitesSnap = await transaction.get(dbGroupUserInvitesRef);
      List<UserInvite> retValInvites = [];
      if (groupUserInvitesSnap.exists) {
        retValInvites = List.of(groupUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }

      Map<String, UserInvite> userInviteMap = {
        for (UserInvite ui in retValInvites) ui.user.email!: ui
      };
      for (UserInvite newUserInvite in userInvites) {
        if (userInviteMap.containsKey(newUserInvite.user.email)) {
          throw Exception("User is already invited to this group");
        }
        retValInvites.add(newUserInvite);
      }

      // for each user, add a userinvite for them
      await Future.wait(userInvites.map((ui) async {
        await addUserInviteForGroup(group, ui, transaction);
      }));
      transaction.set(dbGroupUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> promoteUserGroupInvite(Group group, UserInvite toPromote) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbGroupRef =
          _firebaseFirestore.collection('groups').doc(group.id);

      final groupSnap = await transaction.get(dbGroupRef);
      if (!groupSnap.exists) {
        throw Exception(
            "Unable to add users to group. Group cannot be retrieved.");
      }
      DocumentReference dbGroupUserInvitesRef =
          dbGroupRef.collection('invites').doc("userInvites");

      // before promoting the user, make sure that they are part of the event
      final groupUserInvitesSnap = await transaction.get(dbGroupUserInvitesRef);
      List<UserInvite> retValInvites = [];
      if (groupUserInvitesSnap.exists) {
        retValInvites = List.of(groupUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }
      final indexOfUserInvite = retValInvites
          .indexWhere((element) => element.user.email == toPromote.user.email);
      if (indexOfUserInvite < 0) {
        throw Exception(
            "User is not part of the group. User cannot be promoted.");
      }
      retValInvites[indexOfUserInvite] = UserInvite(
          user: toPromote.user,
          status: toPromote.status,
          type: toPromote.type,
          title: InviteTitle.admin);

      await promoteUserInviteForGroup(group, toPromote, transaction);
      transaction.set(dbGroupUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> editUserGroupInvites(Group group) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbUserGroupInvitesRef = _firebaseFirestore
          .collection('groups')
          .doc(group.id)
          .collection('invites')
          .doc("userInvites");
      DocumentSnapshot dbUserInvitesSnap =
          await transaction.get(dbUserGroupInvitesRef);
      List<UserInvite> dbUserInvites = List.of(dbUserInvitesSnap["userInvites"])
          .map((m) => UserInvite.fromMap(m))
          .toList();

      List<UserInvite> toAdd =
          findUserInvitesDifferences(dbUserInvites, group.userInvites);
      if (toAdd.isNotEmpty) {
        await addUserInvitesForGroup(group, toAdd, transaction);
      }

      List<UserInvite> toRemove =
          findUserInvitesDifferences(group.userInvites, dbUserInvites);

      if (toRemove.isNotEmpty) {
        await removeUserInvitesForGroup(group, toRemove, transaction);
      }
      transaction.update(dbUserGroupInvitesRef, {
        "userInvites": group.userInvites.map((ui) => ui.toDocument()).toList()
      });
    });
  }

  @override
  Future<void> removeUserGroupInvite(
      Group group, UserInvite toRemoveUserInvite) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbGroupRef =
          _firebaseFirestore.collection('groups').doc(group.id);

      final groupSnap = await transaction.get(dbGroupRef);
      if (!groupSnap.exists) {
        throw Exception(
            "Unable to remove user from group. Group cannot be retrieved.");
      }

      DocumentReference dbGroupUserInvitesRef =
          dbGroupRef.collection('invites').doc("userInvites");

      final groupUserInvitesSnap = await transaction.get(dbGroupUserInvitesRef);
      List<UserInvite> retValInvites = [];
      if (groupUserInvitesSnap.exists) {
        retValInvites = List.of(groupUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }

      // check if the user is already part of the invites and add if not
      Map<String, UserInvite> userInviteMap = {
        for (UserInvite ui in retValInvites) ui.user.email!: ui
      };
      if (!userInviteMap.containsKey(toRemoveUserInvite.user.email)) {
        throw Exception(
            "Unable to remove user as they are not part of the group.");
      }

      retValInvites = retValInvites
          .where((element) => element.user != toRemoveUserInvite.user)
          .toList();

      await removeUserInviteForGroup(group, toRemoveUserInvite, transaction);

      transaction.set(dbGroupUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> removeUserGroupInvites(
      Group group, List<UserInvite> toRemoveUserInvites) {
    // TODO: implement removeUserGroupInvites
    throw UnimplementedError();
  }

  @override
  Future<void> removeUserEventInvite(
      HangEvent hangEvent, UserInvite toRemoveUserInvite) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbEventsRef =
          _firebaseFirestore.collection('hangEvents').doc(hangEvent.id);

      final eventsSnap = await transaction.get(dbEventsRef);

      if (!eventsSnap.exists) {
        throw Exception(
            "Unable to remove users from event as event cannot be retrieved.");
      }

      DocumentReference dbEventsUserInvitesRef =
          dbEventsRef.collection('invites').doc("userInvites");

      final eventsUserInvitesSnap =
          await transaction.get(dbEventsUserInvitesRef);

      List<UserInvite> retValInvites = [];
      if (eventsUserInvitesSnap.exists) {
// check if the user is already part of the invites and add if not
        retValInvites = List.of(eventsUserInvitesSnap["userInvites"])
            .map((m) => UserInvite.fromMap(m))
            .toList();
      }

      Map<String, UserInvite> userInviteMap = {
        for (UserInvite ui in retValInvites) ui.user.email!: ui
      };
      if (!userInviteMap.containsKey(toRemoveUserInvite.user.email)) {
        throw Exception(
            "Unable to remove user from event because user is not part of the event.");
      }

      retValInvites = retValInvites
          .where((element) => element.user != toRemoveUserInvite.user)
          .toList();

      await removeUserInviteForEvent(
          hangEvent, toRemoveUserInvite, transaction);

      transaction.set(dbEventsUserInvitesRef,
          {"userInvites": retValInvites.map((ui) => ui.toDocument()).toList()});
    });
  }

  @override
  Future<void> removeUserEventInvites(
      HangEvent hangEvent, List<UserInvite> toRemoveUserInvites) {
    // TODO: implement removeUserEventInvites
    throw UnimplementedError();
  }

  @override
  Future<UserEventMetadata> getUserEventMetadata(String email) async {
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

    return UserEventMetadata(
        userEmail: email,
        numEventsOrganized: eventInvites
            .where((element) => element.title == InviteTitle.organizer)
            .length,
        numEvents: eventInvites.length);
  }
}
