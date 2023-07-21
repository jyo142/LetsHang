import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { error } from "firebase-functions/logger";
import { db } from ".";
import { addNotification, sendNotification } from "./notificationUtils";

export const onUserInvitedToGroup = onDocumentCreated(
  "/groups/{groupId}/invites/{email}",
  async (snap) => {
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
          "name"
        )}, you have been invited to the group :  ${groupSnapshot.get("name")}`
      );
      await addNotification(
        snap.params.email,
        `You have been invited to the group : ${groupSnapshot.get("name")}`,
        { groupId: snap.params.groupId }
      );
    } else {
      error(
        `Unable to send notification to user ${snap.params.email} for group ${snap.params.groupId}`
      );
    }
  }
);

export const onUserPromotedGroup = onDocumentUpdated(
  "/groups/{groupId}/invites/{email}",
  async (snap) => {
    const newUserInviteData = snap.data?.after;
    const oldUserInviteData = snap.data?.before;

    const newUserInviteTitle = newUserInviteData?.get("title");
    const oldUserInviteTitle = oldUserInviteData?.get("title");
    if (!newUserInviteTitle !== oldUserInviteTitle) {
      error("Old titles and new title are not different. exiting");
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
          "name"
        )}, you have been promoted to admin for the group : ${groupSnapshot.get(
          "name"
        )}`
      );
      await addNotification(
        snap.params.email,
        `You have been promoted to admin for the group : ${groupSnapshot.get(
          "name"
        )}`,
        { groupId: snap.params.groupId }
      );
    } else {
      error(
        `Unable to send notification to user ${snap.params.email} for event ${snap.params.groupId}`
      );
    }
  }
);
