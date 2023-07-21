import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { error } from "firebase-functions/logger";
import { db } from ".";
import { addNotification, sendNotification } from "./notificationUtils";

export const onUserInvitedToEvent = onDocumentCreated(
  "/hangEvents/{eventId}/invites/{email}",
  async (snap) => {
    const eventSnapshot = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .get();
    const userSnapshot = await db
      .collection("users")
      .where("email", "==", snap.params.email)
      .get();

    if (eventSnapshot.exists && !userSnapshot.empty) {
      const curUserSnapshot = userSnapshot.docs[0];
      await sendNotification(
        curUserSnapshot,
        "New Event Invitation",
        `Hello ${curUserSnapshot.get(
          "name"
        )}, you have been invited to the event :  ${eventSnapshot.get(
          "eventName"
        )}`
      );

      await addNotification(
        snap.params.email,
        `You have been invited to the event : ${eventSnapshot.get(
          "eventName"
        )}`,
        { eventId: snap.params.eventId }
      );
    } else {
      error(
        `Unable to send notification to user ${snap.params.email} for event ${snap.params.eventId}`
      );
    }
  }
);

export const onUserPromotedEvent = onDocumentUpdated(
  "/hangEvents/{eventId}/invites/{email}",
  async (snap) => {
    const newUserInviteData = snap.data?.after;
    const oldUserInviteData = snap.data?.before;

    const newUserInviteTitle = newUserInviteData?.get("title");
    const oldUserInviteTitle = oldUserInviteData?.get("title");
    if (!newUserInviteTitle !== oldUserInviteTitle) {
      error("Old titles and new title are not different. exiting");
      return;
    }
    const eventSnapshot = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .get();
    const userSnapshot = await db
      .collection("users")
      .where("email", "==", snap.params.email)
      .get();

    if (
      eventSnapshot.exists &&
      !userSnapshot.empty &&
      newUserInviteTitle === "admin"
    ) {
      const curUserSnapshot = userSnapshot.docs[0];
      await sendNotification(
        curUserSnapshot,
        "Event Admin Promotion",
        `Hello ${curUserSnapshot.get(
          "name"
        )}, you have been promoted to admin for the event : ${eventSnapshot.get(
          "eventName"
        )}`
      );

      await addNotification(
        snap.params.email,
        `You have been promoted to admin for the event : ${eventSnapshot.get(
          "eventName"
        )}`,
        { eventId: snap.params.eventId }
      );
    } else {
      error(
        `Unable to send notification to user ${snap.params.email} for event ${snap.params.eventId}`
      );
    }
  }
);
