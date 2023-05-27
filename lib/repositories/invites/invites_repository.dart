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
  Future<List<HangEventInvite>> getAllUserEventInvites(String email) async {
    QuerySnapshot eventInviteSnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(email)
        .collection("eventInvites")
        .get();

    final allDocSnapshots =
        eventInviteSnapshot.docs.map((doc) => doc.data()).toList();

    List<HangEventInvite> eventInvites =
        allDocSnapshots.map((doc) => HangEventInvite.fromMap(doc)).toList();

    List<HangEventInvite> retValInvites = [];
    for (HangEventInvite curEventInvite in eventInvites) {
      DocumentReference eventReference = _firebaseFirestore
          .collection("hangEvents")
          .doc(curEventInvite.event.id);

      // need a reference to the event to get the main event details
      DocumentSnapshot eventSnapshot = await eventReference.get();
      // we need to get all the userInvites for the event to get the event invite previews
      // TODO find a better way to get the "previews" of users per event
      QuerySnapshot eventInviteQuerySnapshot =
          await eventReference.collection("invites").get();
      final allEventInviteDocSnapshots =
          eventInviteQuerySnapshot.docs.map((doc) => doc.data()).toList();
      List<UserInvite> userInvitesForEvent = allEventInviteDocSnapshots
          .map((doc) => UserInvite.fromMap(doc))
          .toList();

      HangEvent curEvent = HangEvent.fromSnapshot(eventSnapshot);
      HangEvent newEvent = curEvent.copyWith(userInvites: userInvitesForEvent);
      retValInvites.add(HangEventInvite(
          event: newEvent,
          status: curEventInvite.status,
          type: curEventInvite.type,
          title: curEventInvite.title,
          eventStartDateTime: newEvent.eventStartDate,
          eventEndDateTime: newEvent.eventEndDate));
    }
    return retValInvites;
  }

  @override
  Future<List<HangEventInvite>> getUserEventInvitesByRange(
      String email, DateTime startDateTime, DateTime endDateTime) async {
    QuerySnapshot rangeEventInviteQuerySnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(email)
        .collection("eventInvites")
        .where('eventStartDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDateTime))
        .where('eventStartDateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDateTime))
        .get();

    QuerySnapshot draftInviteQuerySnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(email)
        .collection("eventInvites")
        .where('eventStartDateTime', isNull: true)
        .get();

    final allRangeDocSnapshots =
        rangeEventInviteQuerySnapshot.docs.map((doc) => doc.data()).toList();
    final allDraftDocSnapshots =
        draftInviteQuerySnapshot.docs.map((doc) => doc.data()).toList();

    List<HangEventInvite> eventInvites = allRangeDocSnapshots
        .map((doc) => HangEventInvite.fromMap(doc))
        .toList();
    List<HangEventInvite> draftEventInvites = allDraftDocSnapshots
        .map((doc) => HangEventInvite.fromMap(doc))
        .toList();

    List<HangEventInvite> allEventInvites = [
      ...eventInvites,
      ...draftEventInvites
    ];

    return allEventInvites;
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
      await Future.wait(userInvites.map((ui) async {
        DocumentReference dbEventsUserInvitesRef =
            dbEventsRef.collection('invites').doc(ui.user.email);
        final dbEventsUserInvitesSnap =
            await transaction.get(dbEventsUserInvitesRef);
        if (!dbEventsUserInvitesSnap.exists) {
          await addUserInviteForEvent(hangEvent, ui, transaction);
          transaction.set(dbEventsUserInvitesRef, ui.toDocument());
        }
        // all reads need to be done before writes
      }));
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
          dbEventsRef.collection('invites').doc(userInvite.user.email);

      final eventsUserInvitesSnap =
          await transaction.get(dbEventsUserInvitesRef);

      if (eventsUserInvitesSnap.exists) {
        throw Exception("User is already invited to this event");
      }

      await addUserInviteForEvent(hangEvent, userInvite, transaction);

      transaction.set(dbEventsUserInvitesRef, userInvite.toDocument());
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
        .doc(hangEvent.id);
    final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

    HangEventInvite newEventInvite = HangEventInvite(
        event: hangEvent,
        status: toAdd.status,
        type: toAdd.type,
        title: toAdd.title,
        eventStartDateTime: hangEvent.eventStartDate,
        eventEndDateTime: hangEvent.eventEndDate);

    if (eventInviteDocumentSnap.exists) {
      throw Exception("User is already invited to this event");
    }

    transaction.set(eventInviteRef, newEventInvite.toDocument());
  }

  Future<void> addUserInvitesForEvent(
      HangEvent event, List<UserInvite> toAdd, Transaction transaction) async {
    await Future.wait(toAdd.map((ui) async {
      DocumentReference eventInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("eventInvites")
          .doc(event.id);
      final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

      HangEventInvite newEventInvite = HangEventInvite(
          event: event,
          status: ui.status,
          type: ui.type,
          title: ui.title,
          eventStartDateTime: event.eventStartDate,
          eventEndDateTime: event.eventEndDate);

      if (eventInviteDocumentSnap.exists) {}
      transaction.set(eventInviteRef, newEventInvite.toDocument());
    }));
  }

  Future<void> removeUserInviteForEvent(
      HangEvent event, UserInvite toRemove, Transaction transaction) async {
    DocumentReference eventInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toRemove.user.email)
        .collection("eventInvites")
        .doc(event.id);
    final eventInviteDocumentSnap = await transaction.get(eventInviteRef);
    if (!eventInviteDocumentSnap.exists) {
      throw Exception("User is not part of the evemt. User cannot be removed.");
    }
    transaction.delete(eventInviteRef);
  }

  Future<void> removeUserInvitesForEvent(HangEvent event,
      List<UserInvite> toRemove, Transaction transaction) async {
    await Future.wait(toRemove.map((ui) async {
      DocumentReference eventInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("eventInvites")
          .doc(event.id);
      final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

      if (eventInviteDocumentSnap.exists) {
        throw Exception(
            "User is not part of the group. User cannot be removed.");
      }
      transaction.delete(eventInviteRef);
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
        .doc(event.id);
    final eventInviteDocumentSnap = await transaction.get(eventInviteRef);

    if (!eventInviteDocumentSnap.exists) {
      throw Exception(
          "User is not part of the group. User cannot be promoted.");
    }
    HangEventInvite curHangEventInvite =
        HangEventInvite.fromSnapshot(eventInviteDocumentSnap);
    HangEventInvite newHangEventInvite = HangEventInvite(
        event: curHangEventInvite.event,
        status: curHangEventInvite.status,
        type: curHangEventInvite.type,
        title: InviteTitle.admin,
        eventStartDateTime: curHangEventInvite.event.eventStartDate,
        eventEndDateTime: curHangEventInvite.event.eventEndDate);

    transaction.update(eventInviteRef, newHangEventInvite.toDocument());
  }

  @override
  Future<void> promoteUserEventInvite(
      HangEvent hangEvent, UserInvite toPromote) async {
    await _firebaseFirestore.runTransaction((transaction) async {
      DocumentReference dbEventsRef =
          _firebaseFirestore.collection('hangEvents').doc(hangEvent.id);

      final eventSnap = await transaction.get(dbEventsRef);
      if (!eventSnap.exists) {
        throw Exception(
            "Unable to promote user in event. Event cannot be retrieved.");
      }
      final dbEventUserInvitesRef =
          dbEventsRef.collection('invites').doc(toPromote.user.email);
      final userInviteSnap = await transaction.get(dbEventUserInvitesRef);
      if (!userInviteSnap.exists) {
        throw Exception(
            "Unable to promote user in event. User is not part of this event.");
      }

      UserInvite newUserInvite = UserInvite(
          user: toPromote.user,
          status: toPromote.status,
          type: toPromote.type,
          title: InviteTitle.admin);

      await promoteUserInviteForEvent(hangEvent, toPromote, transaction);
      transaction.set(dbEventUserInvitesRef, newUserInvite.toDocument());
    });
  }

  @override
  Future<List<GroupInvite>> getUserGroupInvites(String email) async {
    QuerySnapshot groupInviteQuerySnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(email)
        .collection("groupInvites")
        .get();

    final allDocSnapshots =
        groupInviteQuerySnapshot.docs.map((doc) => doc.data()).toList();

    List<GroupInvite> groupInvites =
        allDocSnapshots.map((doc) => GroupInvite.fromMap(doc)).toList();

    List<GroupInvite> retValInvites = [];
    for (GroupInvite curGroupInvite in groupInvites) {
      DocumentReference groupReference =
          _firebaseFirestore.collection("groups").doc(curGroupInvite.group.id);

      // need a reference to the group to get the main group details
      DocumentSnapshot groupSnapshot = await groupReference.get();
      // we need to get all the userInvites for the group to get the group invite previews
      QuerySnapshot groupUserInviteQuerySnapshot =
          await groupReference.collection("invites").get();
      final allGroupUserInviteQuerySnapshot =
          groupUserInviteQuerySnapshot.docs.map((doc) => doc.data()).toList();

      List<UserInvite> groupUserInvites = allGroupUserInviteQuerySnapshot
          .map((doc) => UserInvite.fromMap(doc))
          .toList();
      Group curGroup = Group.fromSnapshot(groupSnapshot);
      Group newGroup = curGroup.copyWith(userInvites: groupUserInvites);
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
        .doc(group.id);
    final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

    if (groupInviteDocumentSnap.exists) {
      throw Exception("User is already invited to this group");
    }
    GroupInvite newGroupInvite = GroupInvite(
        group: group,
        status: toAdd.status,
        type: toAdd.type,
        title: toAdd.title);

    transaction.set(groupInviteRef, newGroupInvite.toDocument());
  }

  Future<void> addUserInvitesForGroup(
      Group group, List<UserInvite> toAdd, Transaction transaction) async {
    await Future.wait(toAdd.map((ui) async {
      DocumentReference groupInviteRef = _firebaseFirestore
          .collection("userInvites")
          .doc(ui.user.userName)
          .collection("groupInvites")
          .doc(group.id);
      final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

      GroupInvite newEventInvite =
          GroupInvite(group: group, status: ui.status, type: ui.type);

      if (!groupInviteDocumentSnap.exists) {
        transaction.set(groupInviteRef, newEventInvite.toDocument());
      }
    }));
  }

  Future<void> removeUserInviteForGroup(
      Group group, UserInvite toRemove, Transaction transaction) async {
    DocumentReference groupInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toRemove.user.email)
        .collection("groupInvites")
        .doc(group.id);
    final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

    List<GroupInvite> retValGroups = [];
    if (!groupInviteDocumentSnap.exists) {
      throw Exception(
          "User cannot be removed from group. User is not part of the group");
    }
    transaction.delete(groupInviteRef);
  }

  Future<void> promoteUserInviteForGroup(
      Group group, UserInvite toPromote, Transaction transaction) async {
    DocumentReference groupInviteRef = _firebaseFirestore
        .collection("userInvites")
        .doc(toPromote.user.email)
        .collection("groupInvites")
        .doc(group.id);
    final groupInviteDocumentSnap = await transaction.get(groupInviteRef);

    if (!groupInviteDocumentSnap.exists) {
      throw Exception(
          "User is not part of the group. User cannot be promoted.");
    }
    GroupInvite dbGroupInvite =
        GroupInvite.fromSnapshot(groupInviteDocumentSnap);
    GroupInvite newGroupInvite = GroupInvite(
        group: dbGroupInvite.group,
        status: dbGroupInvite.status,
        type: dbGroupInvite.type,
        title: InviteTitle.admin);

    transaction.update(groupInviteRef, newGroupInvite.toDocument());
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
          dbGroupRef.collection('invites').doc(userInvite.user.email);

      final groupUserInvitesSnap = await transaction.get(dbGroupUserInvitesRef);
      if (groupUserInvitesSnap.exists) {
        throw Exception("User is already invited to this group");
      }

      await addUserInviteForGroup(group, userInvite, transaction);

      transaction.set(dbGroupUserInvitesRef, userInvite.toDocument());
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
      await Future.wait(userInvites.map((ui) async {
        DocumentReference dbGroupsUserInvitesRef =
            dbGroupRef.collection('invites').doc(ui.user.email);
        final dbEventsUserInvitesSnap =
            await transaction.get(dbGroupsUserInvitesRef);
        if (!dbEventsUserInvitesSnap.exists) {
          await addUserInviteForGroup(group, ui, transaction);
          transaction.set(dbGroupsUserInvitesRef, ui.toDocument());
        }
        // all reads need to be done before writes
      }));
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
          dbGroupRef.collection('invites').doc(toPromote.user.email);

      // before promoting the user, make sure that they are part of the event
      final groupUserInvitesSnap = await transaction.get(dbGroupUserInvitesRef);
      if (groupUserInvitesSnap.exists) {
        throw Exception(
            "User is not part of the group. User cannot be promoted.");
      }
      UserInvite newUserInvite = UserInvite(
          user: toPromote.user,
          status: toPromote.status,
          type: toPromote.type,
          title: InviteTitle.admin);

      await promoteUserInviteForGroup(group, toPromote, transaction);
      transaction.set(dbGroupUserInvitesRef, newUserInvite.toDocument());
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
          dbGroupRef.collection('invites').doc(toRemoveUserInvite.user.email);

      final groupUserInvitesSnap = await transaction.get(dbGroupUserInvitesRef);
      if (!groupUserInvitesSnap.exists) {
        throw Exception(
            "Unable to remove user as they are not part of the group.");
      }

      await removeUserInviteForGroup(group, toRemoveUserInvite, transaction);

      transaction.delete(dbGroupUserInvitesRef);
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
          dbEventsRef.collection('invites').doc(toRemoveUserInvite.user.email);

      final eventsUserInvitesSnap =
          await transaction.get(dbEventsUserInvitesRef);

      if (!eventsUserInvitesSnap.exists) {
        throw Exception(
            "Unable to remove user from event because user is not part of the event.");
      }

      await removeUserInviteForEvent(
          hangEvent, toRemoveUserInvite, transaction);

      transaction.delete(dbEventsUserInvitesRef);
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
    QuerySnapshot eventInviteQuerySnapshot = await _firebaseFirestore
        .collection("userInvites")
        .doc(email)
        .collection("eventInvites")
        .get();

    final allDocSnapshots =
        eventInviteQuerySnapshot.docs.map((doc) => doc.data()).toList();

    List<HangEventInvite> eventInvites =
        allDocSnapshots.map((doc) => HangEventInvite.fromMap(doc)).toList();

    return UserEventMetadata(
        userEmail: email,
        numEventsOrganized: eventInvites
            .where((element) => element.title == InviteTitle.organizer)
            .length,
        numEvents: eventInvites.length);
  }
}
