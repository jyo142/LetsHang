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
import { OAuth2Client } from "googleapis-common";
import { calendar } from "@googleapis/calendar";
import { getAccessTokenFromRefreshToken } from "./services/googleAuthService";
import {
  addUserToDiscussion,
  createUserDiscussionsFromEvent,
  findNewDiscussionMembers,
  removeUserDiscussionForUser,
  removeUserFromDiscussion,
} from "./discussionUtils";

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

        // add the user to discussion
        const eventDiscussionsColRef = db
          .collection("hangEvents")
          .doc(snap.params.eventId)
          .collection("discussions");
        const mainEventDiscussionSnap = await eventDiscussionsColRef
          .where("isMainDiscussion", "==", true)
          .get();
        if (!mainEventDiscussionSnap.empty) {
          const newUserDiscussionMember = {
            userId: userSnapshot.get("id"),
            name: userSnapshot.get("name"),
            email: userSnapshot.get("email"),
            userName: userSnapshot.get("userName"),
            photoUrl: userSnapshot.get("photoUrl"),
          };
          await addUserToDiscussion(
            snap.params.userId,
            eventDiscussionsColRef,
            mainEventDiscussionSnap,
            newUserDiscussionMember,
          );

          const mainDiscussionSnap = mainEventDiscussionSnap.docs[0];
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

          await createUserDiscussionsFromEvent(
            mainDiscussionSnap,
            newDiscussionMembers,
            snap.params.eventId,
          );
        } else {
          info(
            "UNABLE TO FIND MAIN EVENT DISCUSSION FOR EVENT ",
            snap.params.eventId,
          );
        }
      }
    }
  },
);

export const onUserEventInviteDeleted = onDocumentDeleted(
  "/hangEvents/{eventId}/invites/{userId}",
  async (snap) => {
    // check that userInvite for event is deleted as well
    const userInvitesEventInvitesColRef = db
      .collection("userInvites")
      .doc(snap.params.userId)
      .collection("eventInvites");
    const userInviteForEventSnap = await userInvitesEventInvitesColRef
      .where("event.eventId", "==", snap.params.eventId)
      .get();

    if (!userInviteForEventSnap.empty) {
      info("REMOVING USER INVITE FOR EVENT ", snap.params.eventId);
      const userInviteForEventId = userInviteForEventSnap.docs[0].id;
      await userInvitesEventInvitesColRef.doc(userInviteForEventId).delete();
    } else {
      info("USER INVITE FOR EVENT ALREADY REMOVED", snap.params.eventId);
    }

    // first get rid of the user from the main discusssion in the event
    const hangEventDiscussionsColRef = db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .collection("discussions");
    const mainEventDiscussionSnap = await hangEventDiscussionsColRef
      .where("isMainDiscussion", "==", true)
      .get();

    if (!mainEventDiscussionSnap.empty) {
      info("REMOVING USER FROM DISCUSSION. ", snap.params.userId);
      await removeUserFromDiscussion(
        snap.params.userId,
        hangEventDiscussionsColRef,
        mainEventDiscussionSnap,
      );
    } else {
      info(
        "UNABLE TO FIND MAIN EVENT DISCUSSION FOR EVENT ",
        snap.params.eventId,
      );
    }

    // remove the userDiscussion for the event as well
    const userDiscussionDiscussionsColRef = db
      .collection("userDiscussions")
      .doc(snap.params.userId)
      .collection("discussions");

    const eventUserDiscussionSnap = await userDiscussionDiscussionsColRef
      .where("event.eventId", "==", snap.params.eventId)
      .get();
    if (!eventUserDiscussionSnap.empty) {
      await removeUserDiscussionForUser(
        snap.params.userId,
        userDiscussionDiscussionsColRef,
        eventUserDiscussionSnap.docs[0].id,
      );
    } else {
      info("UNABLE TO FIND USER DISCUSSION FOR EVENT ", snap.params.eventId);
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

    await createUserDiscussionsFromEvent(
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
    await createUserDiscussionsFromEvent(
      snapData,
      discussionMembers,
      snap.params.eventId,
    );
  },
);

export const onEventAnnouncementCreated = onDocumentCreated(
  "/hangEvents/{eventId}/announcements/{eventAnnouncementId}",
  async (snap) => {
    if (!snap.data) {
      info("No data");
      return;
    }

    const eventSnapshot = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .get();

    const nonRejectedUserInvites = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .collection("invites")
      .where("status", "!=", "rejected")
      .get();

    if (!nonRejectedUserInvites.empty) {
      for (const curUserInvite of nonRejectedUserInvites.docs) {
        const userId = curUserInvite.data().user.userId;
        if (userId) {
          const creatingUser = snap.data.get("creatingUser");
          if (userId !== creatingUser.userId) {
            // only send the announcement notifications to the users that did not create the announcement
            const userSnapshot = await db.collection("users").doc(userId).get();
            info("Sending Announcement to user : ", userId);
            const newNotification = await addNotification(
              userSnapshot.id,
              `EVENT ANNOUNCEMENT : ${snap.data.get("announcementContent")}`,
              { eventId: snap.params.eventId },
              snap.data.get("invitingUser"),
              eventSnapshot.get("eventEndDate"),
              "eventAnnouncement",
            );

            await sendNotification(
              userSnapshot,
              `Announcement for event : ${eventSnapshot.get("eventName")}`,
              `EVENT ANNOUNCEMENT : ${snap.data.get("announcementContent")}`,
              newNotification.id,
              snap.params.eventId,
              "Event",
              "Announcement",
            );
          }
        }
      }
    }
  },
);

export const onEventPollCreated = onDocumentCreated(
  "/hangEvents/{eventId}/polls/{eventPollId}",
  async (snap) => {
    if (!snap.data) {
      info("No data");
      return;
    }

    const eventSnapshot = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .get();

    const nonRejectedUserInvites = await db
      .collection("hangEvents")
      .doc(snap.params.eventId)
      .collection("invites")
      .where("status", "!=", "rejected")
      .get();

    if (!nonRejectedUserInvites.empty) {
      for (const curUserInvite of nonRejectedUserInvites.docs) {
        const userId = curUserInvite.data().user.userId;
        if (userId) {
          const creatingUser = snap.data.get("creatingUser");
          if (userId !== creatingUser.userId) {
            // only send the announcement notifications to the users that did not create the announcement
            const userSnapshot = await db.collection("users").doc(userId).get();
            info("Sending Poll notification to user : ", userId);
            const newNotification = await addNotification(
              userSnapshot.id,
              `NEW POLL : ${snap.data.get("pollName")}`,
              { eventId: snap.params.eventId },
              snap.data.get("invitingUser"),
              eventSnapshot.get("eventEndDate"),
              "eventPoll",
            );

            await sendNotification(
              userSnapshot,
              `New poll for event : ${eventSnapshot.get("eventName")}`,
              `NEW POLL : ${snap.data.get("pollName")}`,
              newNotification.id,
              snap.params.eventId,
              "Event",
              "NewPoll",
              {
                eventPollId: snap.params.eventPollId,
              },
            );
          }
        }
      }
    }
  },
);
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
