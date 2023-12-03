import {
  DocumentSnapshot,
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { error, info } from "firebase-functions/logger";
import { db } from ".";
import { addNotification, sendNotification } from "./notificationUtils";
import { getStatusTitleDescription } from "./inviteStatusUtils";
import { OAuth2Client } from "googleapis-common";
import { calendar } from "@googleapis/calendar";
import { getAccessTokenFromRefreshToken } from "./services/googleAuthService";

export const onUserInvitedToEvent = onDocumentCreated(
  "/hangEvents/{eventId}/invites/{userId}",
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
      .doc(snap.params.userId)
      .get();

    if (eventSnapshot.exists && userSnapshot.exists) {
      const newNotification = await addNotification(
        snap.params.userId,
        `You have been invited to the event : ${eventSnapshot.get(
          "eventName",
        )}`,
        { eventId: snap.params.eventId },
        snap.data.get("invitingUser"),
        eventSnapshot.get("eventEndDate"),
        "invitation",
      );

      await sendNotification(
        userSnapshot,
        "New Event Invitation",
        `Hello ${userSnapshot.get(
          "name",
        )}, you have been invited to the event :  ${eventSnapshot.get(
          "eventName",
        )}`,
        newNotification.id,
        snap.params.eventId,
        "Event",
        "Invitation",
      );
    } else {
      error(
        `Unable to send notification to user ${snap.params.userId} for event ${snap.params.eventId}`,
      );
    }
  },
);

export const onUserEventInviteChanged = onDocumentUpdated(
  "/hangEvents/{eventId}/invites/{userId}",
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
      .doc(snap.params.userId)
      .get();

    if (isTitleDifferent) {
      await handleUserPromotionEvent(
        eventSnapshot,
        userSnapshot,
        newUserInviteTitle,
        snap.params.userId,
        snap.params.eventId,
        newUserInviteData?.get("invitingUser"),
      );
    }
    if (isStatusDifferent) {
      await handleUserStatusChange(
        eventSnapshot,
        userSnapshot,
        newUserInviteStatus,
        snap.params.eventId,
        newUserInviteData?.get("invitingUser"),
      );

      if (newUserInviteStatus === "accepted") {
        await sendGoogleCalendarInvite(snap.params.userId, eventSnapshot);
      }
    }
  },
);

export const onEventDiscussionModified = onDocumentUpdated(
  "/hangEvents/{eventId}/discussions/{eventDiscussionId}",
  async (snap) => {
    if (!snap.data) {
      info("No data");
      return;
    }

    const newDiscussionData = snap.data?.after;
    const oldDiscussionData = snap.data?.before;

    const snapData = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .collection("discussions")
      .doc(snap.params.eventDiscussionId)
      .get();

    if (!snapData) {
      error("Unable to get snapshot data");
      return;
    }
    // create user discussions for all users in the event discussion
    const newDiscussionMembers = findNewDiscussionMembers(
      oldDiscussionData.get("discussionMembers"),
      newDiscussionData.get("discussionMembers"),
    );

    await createUserDiscussions(
      snapData,
      newDiscussionMembers,
      snap.params.eventId,
    );
  },
);

export const onEventDiscussionCreated = onDocumentCreated(
  "/hangEvents/{eventId}/discussions/{eventDiscussionId}",
  async (snap) => {
    if (!snap.data) {
      info("No data");
      return;
    }

    const snapData = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .collection("discussions")
      .doc(snap.params.eventDiscussionId)
      .get();

    if (!snapData) {
      error("Unable to get snapshot data");
      return;
    }
    const discussionMembers = await snapData.get("discussionMembers");
    // create user discussions for all users in the event discussion
    await createUserDiscussions(
      snapData,
      discussionMembers,
      snap.params.eventId,
    );
  },
);

const findNewDiscussionMembers = (
  oldDiscussionMembers: any[],
  newDiscussionMembers: any[],
) => {
  const newUsers = newDiscussionMembers.filter(
    (nm) =>
      !oldDiscussionMembers.find((om) => om.get("userId") === nm.get("userId")),
  );
  return newUsers;
};

const createUserDiscussions = async (
  eventDiscussionSnapshot: DocumentSnapshot,
  discussionMembers: any[],
  eventId: string,
) => {
  const discussionId = await eventDiscussionSnapshot.get("discussionId");
  const eventPreviewData = eventDiscussionSnapshot.get("event");

  info(discussionMembers);
  for (const curDiscussionMember of discussionMembers) {
    // check if every member of the discussion has their own userDiscussion
    const userDiscussionQuerySnap = await db
      .collection("userDiscussions")
      .where("discussionId", "==", discussionId)
      .get();
    if (userDiscussionQuerySnap.empty) {
      const newUserDiscussion = {
        userId: curDiscussionMember.userId,
        discussionId,
        discussionMembers,
        isMainDiscussion: false,
        event: {
          eventId: eventId,
          eventName: eventPreviewData?.eventName,
          eventDescription: eventPreviewData?.eventDescription,
          photoUrl: eventPreviewData?.photoUrl,
        },
      };
      info("CREATING DISCUSSION FOR USER ", curDiscussionMember.userId);
      await db
        .collection("userDiscussions")
        .doc(curDiscussionMember.userId)
        .collection("discussions")
        .add(newUserDiscussion);
    }
  }
};

const handleUserPromotionEvent = async (
  eventSnapshot: DocumentSnapshot,
  userSnapshot: DocumentSnapshot,
  newUserInviteTitle: string,
  userId: string,
  eventId: string,
  invitingUser?: any,
) => {
  if (
    eventSnapshot.exists &&
    userSnapshot.exists &&
    newUserInviteTitle === "admin"
  ) {
    const newNotification = await addNotification(
      userId,
      `You have been promoted to admin for the event : ${eventSnapshot.get(
        "eventName",
      )}`,
      { eventId: eventId },
      invitingUser,
      eventSnapshot.get("eventEndDate"),
      "promotion",
    );
    await sendNotification(
      userSnapshot,
      "Event Admin Promotion",
      `Hello ${userSnapshot.get(
        "name",
      )}, you have been promoted to admin for the event : ${eventSnapshot.get(
        "eventName",
      )}`,
      newNotification.id,
      eventId,
      "Event",
      "Promotion",
    );
  } else {
    error(`Unable to send notification to user ${userId} for event ${eventId}`);
  }
};

const sendGoogleCalendarInvite = async (
  userId: string,
  eventSnapshot: DocumentSnapshot,
) => {
  info("Sending google calendar invite");
  const userSettingsSnapshot = await db
    .collection("userSettings")
    .doc(userId)
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
  userSnapshot: DocumentSnapshot,
  newUserStatus: string,
  eventId: string,
  invitingUser?: any,
) => {
  const eventOwner = eventSnapshot.get("eventOwner");
  if (eventSnapshot.exists && userSnapshot.exists) {
    const titleDescription = getStatusTitleDescription(
      "Event",
      newUserStatus,
      userSnapshot,
      eventSnapshot.get("eventName"),
    );
    const newNotification = await addNotification(
      eventOwner.userId,
      titleDescription.description,
      {
        eventId: eventId,
      },
      invitingUser,
      eventSnapshot.get("eventEndDate"),
    );

    await sendNotification(
      userSnapshot,
      titleDescription.title,
      titleDescription.description,
      newNotification.id,
      eventId,
      "Event",
      "",
    );
  } else {
    error(
      `Unable to send notification to user ${eventOwner.email} for event ${eventId}`,
    );
  }
};
