import * as admin from "firebase-admin";
import { DocumentSnapshot } from "firebase-functions/v2/firestore";
import { info, error } from "firebase-functions/logger";
import { db } from ".";
import { DocumentReference } from "firebase-admin/firestore";

export interface NotificationsMetadata {
  groupId?: string;
  eventId?: string;
}
export const addNotification = async (
  userId: string,
  content: string,
  metadata?: NotificationsMetadata,
  initiatedUserData?: any,
  expirationDate?: number,
  notificationType?: string,
): Promise<DocumentReference> => {
  const pendingNotificationCollectionRef = db
    .collection("notifications")
    .doc(userId)
    .collection("pendingNotifications");
  info(initiatedUserData);

  const retVal: any = {
    id: pendingNotificationCollectionRef.doc().id,
    userId,
    content,
    createdDate: admin.firestore.Timestamp.fromDate(new Date()),
    notificationType,
    ...metadata,
  };
  if (expirationDate) {
    retVal["expirationDate"] = expirationDate;
  }
  if (initiatedUserData) {
    const initiatedUserPhotoUrl = initiatedUserData["photoUrl"];
    if (initiatedUserPhotoUrl) {
      retVal["initiatedUserPhotoUrl"] = initiatedUserData["photoUrl"];
    }
    const initiatedUserName = initiatedUserData["name"];
    if (initiatedUserName) {
      retVal["initiatedUserName"] = initiatedUserData["name"];
    }
  }
  const newNotification = await pendingNotificationCollectionRef.add(retVal);
  return newNotification;
};

export const sendNotification = async (
  curUserSnapshot: DocumentSnapshot,
  notificationTitle: string,
  notificationBody: string,
  notificationId: string,
  entityId: string,
  entityType: string,
  notificationType: string,
  extraData?: object,
) => {
  info(`PENDING : sending notifiation to user ${curUserSnapshot.get("email")}`);
  const userFCMToken = curUserSnapshot.get("fcmToken");
  if (userFCMToken == null) {
    error(
      `User does not have a fcm token, cannot send a notification. user : ${curUserSnapshot.get(
        "email",
      )}`,
    );
  } else {
    await admin.messaging().send({
      token: curUserSnapshot.get("fcmToken"),
      notification: {
        title: notificationTitle,
        body: notificationBody,
      },
      data: {
        userId: curUserSnapshot.get("id"),
        notificationId,
        entityId,
        entityType,
        notificationType,
        ...extraData,
      },
    });
    info(
      `SUCCESS : sending notifiation to user ${curUserSnapshot.get("email")}`,
    );
  }
};
