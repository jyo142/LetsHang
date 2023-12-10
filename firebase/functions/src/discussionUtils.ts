import { info } from "firebase-functions/logger";
import { db } from ".";
import { DocumentSnapshot } from "firebase-functions/v2/firestore";
import { CollectionReference, QuerySnapshot } from "firebase-admin/firestore";
export const findNewDiscussionMembers = (
  oldDiscussionMembers: any[],
  newDiscussionMembers: any[],
) => {
  const newUsers = newDiscussionMembers.filter(
    (nm) =>
      !oldDiscussionMembers.find((om) => om.get("userId") === nm.get("userId")),
  );
  return newUsers;
};

export const createUserDiscussionsFromEvent = async (
  eventDiscussionSnapshot: DocumentSnapshot,
  discussionMembers: any[],
  eventId: string,
) => {
  const discussionId = await eventDiscussionSnapshot.get("discussionId");
  const eventPreviewData = await eventDiscussionSnapshot.get("event");
  await createUserDiscussions(discussionMembers, discussionId, {
    event: {
      eventId: eventId,
      eventName: eventPreviewData?.eventName,
      eventDescription: eventPreviewData?.eventDescription,
      photoUrl: eventPreviewData?.photoUrl,
    },
  });
};

export const createUserDiscussionsFromGroup = async (
  groupDiscussionSnapshot: DocumentSnapshot,
  discussionMembers: any[],
  groupId: string,
) => {
  const discussionId = await groupDiscussionSnapshot.get("discussionId");
  const groupPreviewData = await groupDiscussionSnapshot.get("group");

  await createUserDiscussions(discussionMembers, discussionId, {
    group: {
      groupId: groupId,
      groupName: groupPreviewData?.groupName,
    },
  });
};

export const addUserToDiscussion = async (
  userId: string,
  collectionRef: CollectionReference,
  querySnap: QuerySnapshot,
  newDiscussionUser: any,
) => {
  info("ADDING USER TO MAIN DISCUSSION ", userId);
  const mainDiscussionSnap = querySnap.docs[0];
  const mainDiscussionDataId = mainDiscussionSnap.id;
  const mainDiscussionData = mainDiscussionSnap.data();
  info("DISCUSSION USERS ", mainDiscussionData);
  if (
    !mainDiscussionData.discussionMembers.some((m: any) => m.userId === userId)
  ) {
    mainDiscussionData.discussionMembers = [
      ...mainDiscussionData.discussionMembers,
      newDiscussionUser,
    ];
  }
  info("DISCUSSION DATA ", mainDiscussionData);

  await collectionRef.doc(mainDiscussionDataId).set(mainDiscussionData);
};

export const removeUserFromDiscussion = async (
  userId: string,
  collectionRef: CollectionReference,
  querySnap: QuerySnapshot,
) => {
  info("REMOVING USER FROM DISCUSSION ", userId);
  const mainDiscussionSnap = querySnap.docs[0];
  const mainDiscussionDataId = mainDiscussionSnap.id;
  const mainDiscussionData = mainDiscussionSnap.data();
  mainDiscussionData.discussionMembers =
    mainDiscussionData.discussionMembers.filter(
      (u: any) => u.userId !== userId,
    );
  await collectionRef.doc(mainDiscussionDataId).set(mainDiscussionData);
};

export const removeUserDiscussionForUser = async (
  userId: string,
  collectionRef: CollectionReference,
  userDiscussionId: string,
) => {
  info("REMOVING USER DISCUSSION FOR USER", userId);
  await collectionRef.doc(userDiscussionId).delete();
};

const createUserDiscussions = async (
  discussionMembers: any[],
  discussionId: string,
  metadata: any,
) => {
  for (const curDiscussionMember of discussionMembers) {
    // check if every member of the discussion has their own userDiscussion
    const userDiscussionQuerySnap = await db
      .collection("userDiscussions")
      .doc(curDiscussionMember.userId)
      .collection("discussions")
      .where("discussionId", "==", discussionId)
      .get();
    if (userDiscussionQuerySnap.empty) {
      const newUserDiscussion = {
        userId: curDiscussionMember.userId,
        discussionId,
        discussionMembers,
        isMainDiscussion: false,
        ...metadata,
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
