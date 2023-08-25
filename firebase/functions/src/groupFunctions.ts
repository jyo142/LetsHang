import {
  DocumentSnapshot,
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { error, info } from "firebase-functions/logger";
import { db } from ".";
import { addNotification, sendNotification } from "./notificationUtils";
import { QuerySnapshot } from "firebase-admin/firestore";
import { getStatusTitleDescription } from "./inviteStatusUtils";

export const onUserInvitedToGroup = onDocumentCreated(
  "/groups/{groupId}/invites/{email}",
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
      .where("email", "==", snap.params.email)
      .get();

    if (groupSnapshot.exists && !userSnapshot.empty) {
      const curUserSnapshot = userSnapshot.docs[0];
      await sendNotification(
        curUserSnapshot,
        "New Group Invitation",
        `Hello ${curUserSnapshot.get(
          "name",
        )}, you have been invited to the group :  ${groupSnapshot.get("name")}`,
      );
      await addNotification(
        snap.params.email,
        `You have been invited to the group : ${groupSnapshot.get("name")}`,
        { groupId: snap.params.groupId },
      );
    } else {
      error(
        `Unable to send notification to user ${snap.params.email} for group ${snap.params.groupId}`,
      );
    }
  },
);

export const onUserGroupInviteChanged = onDocumentUpdated(
  "/groups/{groupId}/invites/{email}",
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
      .where("email", "==", snap.params.email)
      .get();

    if (isTitleDifferent) {
      await handleUserPromotionGroup(
        groupSnapshot,
        userSnapshot,
        newUserInviteTitle,
        snap.params.email,
        snap.params.groupId,
      );
    }
    if (isStatusDifferent) {
      await handleUserStatusChange(
        groupSnapshot,
        userSnapshot,
        newUserInviteStatus,
        snap.params.groupId,
      );
    }
  },
);

const handleUserPromotionGroup = async (
  groupSnapshot: DocumentSnapshot,
  userSnapshot: QuerySnapshot,
  newUserInviteTitle: string,
  email: string,
  groupId: string,
) => {
  if (
    groupSnapshot.exists &&
    !userSnapshot.empty &&
    newUserInviteTitle === "admin"
  ) {
    const curUserSnapshot = userSnapshot.docs[0];
    await sendNotification(
      curUserSnapshot,
      "Group Admin Promotion",
      `Hello ${curUserSnapshot.get(
        "name",
      )}, you have been promoted to admin for the group : ${groupSnapshot.get(
        "name",
      )}`,
    );
    await addNotification(
      email,
      `You have been promoted to admin for the group : ${groupSnapshot.get(
        "name",
      )}`,
      { groupId },
    );
  } else {
    error(`Unable to send notification to user ${email} for event ${groupId}`);
  }
};

const handleUserStatusChange = async (
  groupSnapshot: DocumentSnapshot,
  userSnapshot: QuerySnapshot,
  newUserStatus: string,
  groupId: string,
) => {
  const groupOwner = groupSnapshot.get("groupOwner");
  if (groupSnapshot.exists && !userSnapshot.empty) {
    const curUserSnapshot = userSnapshot.docs[0];
    const titleDescription = getStatusTitleDescription(
      "Group",
      newUserStatus,
      curUserSnapshot,
      groupSnapshot.get("name"),
    );
    await sendNotification(
      curUserSnapshot,
      titleDescription.title,
      titleDescription.description,
    );

    await addNotification(groupOwner.email, titleDescription.description);
  } else {
    error(
      `Unable to send notification to user ${groupOwner.email} for group ${groupId}`,
    );
  }
};
