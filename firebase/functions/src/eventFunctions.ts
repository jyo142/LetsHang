import {
  DocumentSnapshot,
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { error } from "firebase-functions/logger";
import { db } from ".";
import { addNotification, sendNotification } from "./notificationUtils";
import { QuerySnapshot } from "firebase-admin/firestore";
import { getStatusTitleDescription } from "./inviteStatusUtils";

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

export const onUserEventInviteChanged = onDocumentUpdated(
  "/hangEvents/{eventId}/invites/{email}",
  async (snap) => {
    const newUserInviteData = snap.data?.after;
    const oldUserInviteData = snap.data?.before;

    // figure out what has been updated
    const newUserInviteTitle = newUserInviteData?.get("title");
    const oldUserInviteTitle = oldUserInviteData?.get("title");
    const isTitleDifferent = newUserInviteTitle !== oldUserInviteTitle;

    const newUserInviteStatus = newUserInviteData?.get("status");
    const oldUserInviteStatus = oldUserInviteData?.get("status");
    const isStatusDifferent = newUserInviteStatus !== oldUserInviteStatus;

    if (!isStatusDifferent && !isTitleDifferent) {
      error("Old data and new data are not different. exiting");
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

    if (isTitleDifferent) {
      await handleUserPromotionEvent(
        eventSnapshot,
        userSnapshot,
        newUserInviteTitle,
        snap.params.email,
        snap.params.eventId
      );
    }
    if (isStatusDifferent) {
      await handleUserStatusChange(
        eventSnapshot,
        userSnapshot,
        newUserInviteStatus,
        snap.params.eventId
      );
    }
  }
);

const handleUserPromotionEvent = async (
  eventSnapshot: DocumentSnapshot,
  userSnapshot: QuerySnapshot,
  newUserInviteTitle: string,
  email: string,
  eventId: string
) => {
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
      email,
      `You have been promoted to admin for the event : ${eventSnapshot.get(
        "eventName"
      )}`,
      { eventId: eventId }
    );
  } else {
    error(`Unable to send notification to user ${email} for event ${eventId}`);
  }
};

const handleUserStatusChange = async (
  eventSnapshot: DocumentSnapshot,
  userSnapshot: QuerySnapshot,
  newUserStatus: string,
  eventId: string
) => {
  const eventOwner = eventSnapshot.get("eventOwner");
  if (eventSnapshot.exists && !userSnapshot.empty) {
    const curUserSnapshot = userSnapshot.docs[0];
    const titleDescription = getStatusTitleDescription(
      "Event",
      newUserStatus,
      curUserSnapshot,
      eventSnapshot.get("eventName")
    );
    await sendNotification(
      curUserSnapshot,
      titleDescription.title,
      titleDescription.description
    );

    await addNotification(eventOwner.email, titleDescription.description, {
      eventId: eventId,
    });
  } else {
    error(
      `Unable to send notification to user ${eventOwner.email} for event ${eventId}`
    );
  }
};
