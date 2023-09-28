import { HttpsError, onCall } from "firebase-functions/v2/https";
import { info } from "firebase-functions/logger";
import { db } from ".";
import { getAccessTokenFromRefreshToken } from "./services/googleAuthService";
import { OAuth2Client } from "googleapis-common";
import { calendar } from "@googleapis/calendar";

export const getCalendarEvents = onCall(async (request) => {
  if (request.auth?.token.email) {
    info("Not authorized to call this");
    throw new HttpsError("unauthenticated", "Not authed");
  }
  const userSettingsDocRef = db
    .collection("userSettings")
    .doc("jyo1291@gmail.com");

  const userSettingsSnapshot = await userSettingsDocRef.get();
  const doesUserSettingsExist = userSettingsSnapshot.exists;
  if (!doesUserSettingsExist) {
    info("User settings does not exist");
    throw new HttpsError("not-found", "No user settings found");
  }
  info("STARTING REQUEST FOR TOKEN NOW");
  const refreshToken = userSettingsSnapshot.get("googleApiRefreshToken");
  if (!refreshToken) {
    throw new HttpsError("not-found", "No token found");
  }
  const accessToken = await getAccessTokenFromRefreshToken(refreshToken);
  const authClient = new OAuth2Client();
  authClient.setCredentials({ access_token: accessToken });
  info("Getting calendar api");
  const calendarApi = await calendar({
    version: "v3",
    auth: authClient,
  });
  const startOfDay = new Date();
  startOfDay.setUTCHours(0, 0, 0, 0);

  const calendarResults = await calendarApi.events.list({
    calendarId: "primary",
    timeMin: startOfDay.toISOString(),
  });
  info("Successful calendar results. Number of events retrieved");
  info(calendarResults);
  // Update the data in the document
  userSettingsDocRef.update({
    googleApiRefreshToken: refreshToken,
  });
});
