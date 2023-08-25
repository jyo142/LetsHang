import { HttpsError, onCall } from "firebase-functions/v2/https";
import { info } from "firebase-functions/logger";
import { db } from ".";
import { getRefreshToken } from "./services/googleAuthService";

export const getUserToken = onCall(
  {
    enforceAppCheck: true, // Reject requests with missing or invalid App Check tokens.
  },
  async (request) => {
    if (request.auth?.token.email) {
      info("Not authorized to call this");
      throw new HttpsError("unauthenticated", "Not authed");
    }
    const userSettingsDocRef = db
      .collection("userSettings")
      .doc(request.auth!.token.email!);

    const doesUserSettingsExist = (await userSettingsDocRef.get()).exists;
    if (!doesUserSettingsExist) {
      info("User settings does not exist");
      throw new HttpsError("not-found", "No user settings found");
    }
    info("STARTING REQUEST FOR TOKEN NOW");

    const refreshToken = await getRefreshToken(request.data.code);
    if (!refreshToken) {
      info("Unable to get");
      throw new HttpsError("internal", "Unable to get refresh token");
    }
    info("Successful call, storing refresh token in db");
    // Update the data in the document
    userSettingsDocRef.update({
      googleApiRefreshToken: refreshToken,
    });
  },
);
