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
import { OAuth2Client } from "googleapis-common";
import { calendar } from "@googleapis/calendar";
import { getAccessTokenFromRefreshToken } from "./services/googleAuthService";

export const onUserInvitedToEvent = onDocumentCreated(
  "/hangEvents/{eventId}/invites/{email}",
  async (snap) => {
    if (!snap.data) {
      info("No data");
      return;
    }
    if (snap.data.get("title") === "organizer") {
      info("Do not send invite for organizers");
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
        { eventId: snap.params.eventId },
        snap.data.get("invitingUser")
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
        snap.params.eventId,
        newUserInviteData?.get("invitingUser")
      );
    }
    if (isStatusDifferent) {
      await handleUserStatusChange(
        eventSnapshot,
        userSnapshot,
        newUserInviteStatus,
        snap.params.eventId,
        newUserInviteData?.get("invitingUser")
      );

      if (newUserInviteStatus === "accepted") {
        await sendGoogleCalendarInvite(snap.params.email, eventSnapshot);
      }
    }
  }
);

const handleUserPromotionEvent = async (
  eventSnapshot: DocumentSnapshot,
  userSnapshot: QuerySnapshot,
  newUserInviteTitle: string,
  email: string,
  eventId: string,
  invitingUser?: any
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
      { eventId: eventId },
      invitingUser
    );
  } else {
    error(`Unable to send notification to user ${email} for event ${eventId}`);
  }
};

const sendGoogleCalendarInvite = async (
  userEmail: string,
  eventSnapshot: DocumentSnapshot
) => {
  info("Sending google calendar invite");
  const userSettingsSnapshot = await db
    .collection("userSettings")
    .doc(userEmail)
    .get();
  // Set the access token obtained after authentication
  const refreshToken = userSettingsSnapshot.get("googleApiRefreshToken");
  const eventStartDate = eventSnapshot.get("eventStartDate");
  const eventEndDate = eventSnapshot.get("eventEndDate");

  if (!refreshToken || !eventStartDate || !eventEndDate) {
    return;
  }
  const accessToken = await getAccessTokenFromRefreshToken(refreshToken);
  if (!accessToken) {
    info("Unable to get access token from refresh token");
    return;
  }
  const authClient = new OAuth2Client();
  authClient.setCredentials({ access_token: accessToken });
  info("Getting calendar api");
  const calendarApi = await calendar({
    version: "v3",
    auth: authClient,
  });
  info("Adding event to calendar");
  const startString = new Date(eventStartDate.toDate()).toISOString();
  const endString = new Date(eventEndDate.toDate()).toISOString();
  info("Start end dates ", startString, endString);
  const response = await calendarApi.events.insert({
    calendarId: "primary",
    sendNotifications: true,
    requestBody: {
      summary: eventSnapshot.get("eventName"),
      description: eventSnapshot.get("eventDescription"),
      start: {
        dateTime: startString,
        timeZone: userSettingsSnapshot.get("userTimezone"),
      },
      end: {
        dateTime: endString,
        timeZone: userSettingsSnapshot.get("userTimezone"),
      },
    },
  });
  info(response);
};

const handleUserStatusChange = async (
  eventSnapshot: DocumentSnapshot,
  userSnapshot: QuerySnapshot,
  newUserStatus: string,
  eventId: string,
  invitingUser?: any
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

    await addNotification(
      eventOwner.email,
      titleDescription.description,
      {
        eventId: eventId,
      },
      invitingUser
    );
  } else {
    error(
      `Unable to send notification to user ${eventOwner.email} for event ${eventId}`
    );
  }
};
