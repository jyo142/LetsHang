import * as admin from "firebase-admin";
import { DocumentSnapshot } from "firebase-functions/v2/firestore";
import { info, error } from "firebase-functions/logger";
import { db } from ".";

export interface NotificationsMetadata {
  groupId?: string;
  eventId?: string;
}
export const addNotification = async (
  userId: string,
  content: string,
  metadata?: NotificationsMetadata,
  initiatedUserData?: any,
  expirationDate?: number
) => {
  const pendingNotificationCollectionRef = db
    .collection("notifications")
    .doc(userId)
    .collection("pendingNotifications");
  info(initiatedUserData);
  await pendingNotificationCollectionRef.add({
    id: pendingNotificationCollectionRef.doc().id,
    userId,
    content,
    createdDate: admin.firestore.Timestamp.fromDate(new Date()),
    expirationDate,
    initiatedUserPhotoUrl: initiatedUserData
      ? initiatedUserData["photoUrl"]
      : null,
    initiatedUserName: initiatedUserData ? initiatedUserData["name"] : null,
    ...metadata,
  });
};

export const sendNotification = async (
  curUserSnapshot: DocumentSnapshot,
  notificationTitle: string,
  notificationBody: string
) => {
  info(`PENDING : sending notifiation to user ${curUserSnapshot.get("email")}`);
  const userFCMToken = curUserSnapshot.get("fcmToken");
  if (userFCMToken == null) {
    error(
      `User does not have a fcm token, cannot send a notification. user : ${curUserSnapshot.get(
        "email"
      )}`
    );
  } else {
    const payload = {
      notification: {
        title: notificationTitle,
        body: notificationBody,
        sound: "default",
        badge: "1",
      },
    };
    await admin
      .messaging()
      .sendToDevice([curUserSnapshot.get("fcmToken")], payload);
    info(
      `SUCCESS : sending notifiation to user ${curUserSnapshot.get("email")}`
    );
  }
};
