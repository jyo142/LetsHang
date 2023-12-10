import {
  DocumentSnapshot,
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { error, info } from "firebase-functions/logger";
import { db } from ".";
import { addNotification, sendNotification } from "./notificationUtils";
import { getStatusTitleDescription } from "./inviteStatusUtils";
import {
  addUserToDiscussion,
  createUserDiscussionsFromGroup,
  removeUserDiscussionForUser,
  removeUserFromDiscussion,
} from "./discussionUtils";

export const onUserInvitedToGroup = onDocumentCreated(
  "/groups/{groupId}/invites/{userId}",
  async (snap) => {
    if (!snap.data) {
      info("No data");
      return;
    }
    if (snap.data.get("title") === "organizer") {
      info("Do not send invite for organizers");
      return;
    }
    const groupSnapshot = await db
      .collection("groups")
      .doc(snap.params.groupId)
      .get();
    const userSnapshot = await db
      .collection("users")
      .doc(snap.params.userId)
      .get();

    if (groupSnapshot.exists && userSnapshot.exists) {
      const newNotification = await addNotification(
        snap.params.userId,
        `You have been invited to the group : ${groupSnapshot.get("name")}`,
        { groupId: snap.params.groupId },
        snap.data.get("invitingUser"),
        undefined,
        "invitation",
      );
      await sendNotification(
        userSnapshot,
        "New Group Invitation",
        `Hello ${userSnapshot.get(
          "name",
        )}, you have been invited to the group :  ${groupSnapshot.get("name")}`,
        newNotification.id,
        snap.params.groupId,
        "Group",
        "Invitation",
      );
    } else {
      error(
        `Unable to send notification to user ${snap.params.userId} for group ${snap.params.groupId}`,
      );
    }
  },
);

export const onUserGroupInviteChanged = onDocumentUpdated(
  "/groups/{groupId}/invites/{userId}",
  async (snap) => {
    const newUserInviteData = snap.data?.after;
    const oldUserInviteData = snap.data?.before;

    // figure out what has been updated
    const newUserInviteTitle = newUserInviteData?.get("title");
    const oldUserInviteTitle = oldUserInviteData?.get("title");
    const isTitleDifferent = newUserInviteTitle !== oldUserInviteTitle;

    if (newUserInviteTitle === "organzier") {
      info("Do not send invite for organizers");
      return;
    }
    const newUserInviteStatus = newUserInviteData?.get("status");
    const oldUserInviteStatus = oldUserInviteData?.get("status");
    const isStatusDifferent = newUserInviteStatus !== oldUserInviteStatus;

    if (!isStatusDifferent && !isTitleDifferent) {
      error("Old data and new data are not different. exiting");
      return;
    }
    const groupSnapshot = await db
      .collection("groups")
      .doc(snap.params.groupId)
      .get();
    const userSnapshot = await db
      .collection("users")
      .doc(snap.params.userId)
      .get();

    if (isTitleDifferent) {
      await handleUserPromotionGroup(
        groupSnapshot,
        userSnapshot,
        newUserInviteTitle,
        snap.params.userId,
        snap.params.groupId,
        newUserInviteData?.get("invitingUser"),
      );
    }
    if (isStatusDifferent) {
      await handleUserStatusChange(
        groupSnapshot,
        userSnapshot,
        newUserInviteStatus,
        snap.params.groupId,
        newUserInviteData?.get("invitingUser"),
      );

      if (newUserInviteStatus === "accepted") {
        // add the user to discussion
        const groupDiscussionsColRef = db
          .collection("groups")
          .doc(snap.params.groupId)
          .collection("discussions");
        const mainGroupDiscussionSnap = await groupDiscussionsColRef
          .where("isMainDiscussion", "==", true)
          .get();
        if (!mainGroupDiscussionSnap.empty) {
          const newUserDiscussionMember = {
            userId: userSnapshot.get("id"),
            name: userSnapshot.get("name"),
            email: userSnapshot.get("email"),
            userName: userSnapshot.get("userName"),
            photoUrl: userSnapshot.get("photoUrl"),
          };
          await addUserToDiscussion(
            snap.params.userId,
            groupDiscussionsColRef,
            mainGroupDiscussionSnap,
            newUserDiscussionMember,
          );

          const mainDiscussionSnap = mainGroupDiscussionSnap.docs[0];
          const mainDiscussionData = mainDiscussionSnap.data();
          const newDiscussionMembers = mainDiscussionData.discussionMembers;
          if (
            !newDiscussionMembers.some(
              (u: any) => u.userId === newUserDiscussionMember.userId,
            )
          ) {
            newDiscussionMembers.push(newUserDiscussionMember);
          }
          info("NEW DISCUSSION MEMBERS ", newDiscussionMembers);

          await createUserDiscussionsFromGroup(
            mainDiscussionSnap,
            newDiscussionMembers,
            snap.params.groupId,
          );
        } else {
          info(
            "UNABLE TO FIND MAIN GROUP DISCUSSION FOR GROUP ",
            snap.params.groupId,
          );
        }
      }
    }
  },
);

export const onUserGroupInviteDeleted = onDocumentDeleted(
  "/groups/{groupId}/invites/{userId}",
  async (snap) => {
    // check that userInvite for event is deleted as well
    const userInvitesGroupInvitesColRef = db
      .collection("userInvites")
      .doc(snap.params.userId)
      .collection("groupInvites");
    const userInviteForGroupSnap = await userInvitesGroupInvitesColRef
      .where("group.id", "==", snap.params.groupId)
      .get();

    if (!userInviteForGroupSnap.empty) {
      info("REMOVING USER INVITE FOR GROUP ", snap.params.groupId);
      const userInviteForGroupId = userInviteForGroupSnap.docs[0].id;
      await userInvitesGroupInvitesColRef.doc(userInviteForGroupId).delete();
    } else {
      info("USER INVITE FOR GROUP ALREADY REMOVED", snap.params.groupId);
    }

    // first get rid of the user from the main discusssion in the event
    const groupDiscussionsColRef = db
      .collection("groups")
      .doc(snap.params.groupId)
      .collection("discussions");
    const mainGroupDiscussionSnap = await groupDiscussionsColRef
      .where("isMainDiscussion", "==", true)
      .get();

    if (!mainGroupDiscussionSnap.empty) {
      info("REMOVING USER FROM DISCUSSION ", snap.params.userId);
      await removeUserFromDiscussion(
        snap.params.userId,
        groupDiscussionsColRef,
        mainGroupDiscussionSnap,
      );
    } else {
      info(
        "UNABLE TO FIND MAIN GROUP DISCUSSION FOR GROUP ",
        snap.params.groupId,
      );
    }

    // remove the userDiscussion for the event as well
    const userDiscussionDiscussionsColRef = db
      .collection("userDiscussions")
      .doc(snap.params.userId)
      .collection("discussions");

    const groupUserDiscussionSnap = await userDiscussionDiscussionsColRef
      .where("group.groupId", "==", snap.params.groupId)
      .get();
    if (!groupUserDiscussionSnap.empty) {
      await removeUserDiscussionForUser(
        snap.params.userId,
        userDiscussionDiscussionsColRef,
        groupUserDiscussionSnap.docs[0].id,
      );
    } else {
      info("UNABLE TO FIND USER DISCUSSION FOR GROUP ", snap.params.groupId);
    }
  },
);

export const onGroupDiscussionCreated = onDocumentCreated(
  "/groups/{groupId}/discussions/{groupDiscussionId}",
  async (snap) => {
    if (!snap.data) {
      info("No data");
      return;
    }

    const snapData = await db
      .collection("groups")
      .doc(snap.params.groupId)
      .collection("discussions")
      .doc(snap.params.groupDiscussionId)
      .get();

    if (!snapData) {
      error("Unable to get snapshot data");
      return;
    }
    const discussionMembers = await snapData.get("discussionMembers");
    // create user discussions for all users in the event discussion
    await createUserDiscussionsFromGroup(
      snapData,
      discussionMembers,
      snap.params.groupId,
    );
  },
);

const handleUserPromotionGroup = async (
  groupSnapshot: DocumentSnapshot,
  userSnapshot: DocumentSnapshot,
  newUserInviteTitle: string,
  userId: string,
  groupId: string,
  invitingUser?: any,
) => {
  if (
    groupSnapshot.exists &&
    userSnapshot.exists &&
    newUserInviteTitle === "admin"
  ) {
    const newNotification = await addNotification(
      userId,
      `You have been promoted to admin for the group : ${groupSnapshot.get(
        "name",
      )}`,
      { groupId },
      invitingUser,
      undefined,
      "promotion",
    );
    await sendNotification(
      userSnapshot,
      "Group Admin Promotion",
      `Hello ${userSnapshot.get(
        "name",
      )}, you have been promoted to admin for the group : ${groupSnapshot.get(
        "name",
      )}`,
      newNotification.id,
      groupId,
      "Group",
      "Promotion",
    );
  } else {
    error(`Unable to send notification to user ${userId} for event ${groupId}`);
  }
};

const handleUserStatusChange = async (
  groupSnapshot: DocumentSnapshot,
  userSnapshot: DocumentSnapshot,
  newUserStatus: string,
  groupId: string,
  invitingUser?: DocumentSnapshot,
) => {
  const groupOwner = groupSnapshot.get("groupOwner");
  if (groupSnapshot.exists && userSnapshot.exists) {
    const titleDescription = getStatusTitleDescription(
      "Group",
      newUserStatus,
      userSnapshot,
      groupSnapshot.get("name"),
    );
    const newNotification = await addNotification(
      groupOwner.userId,
      titleDescription.description,
      { groupId },
      invitingUser,
      undefined,
      "statusChange",
    );
    await sendNotification(
      userSnapshot,
      titleDescription.title,
      titleDescription.description,
      newNotification.id,
      groupId,
      "Group",
      "",
    );
  } else {
    error(
      `Unable to send notification to user ${groupOwner.email} for group ${groupId}`,
    );
  }
};
