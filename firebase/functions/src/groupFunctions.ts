import {
  DocumentSnapshot,
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { error, info } from "firebase-functions/logger";
import { db } from ".";
import { addNotification, sendNotification } from "./notificationUtils";
import { getStatusTitleDescription } from "./inviteStatusUtils";

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
    }
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
