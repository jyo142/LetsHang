import { info } from "firebase-functions/logger";
import { db } from ".";
import { DocumentSnapshot } from "firebase-functions/v2/firestore";
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

const createUserDiscussions = async (
  discussionMembers: any[],
  discussionId: string,
  metadata: any,
) => {
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
        ...metadata,
      };
      info("GGGGG ", newUserDiscussion);
      info("CREATING DISCUSSION FOR USER ", curDiscussionMember.userId);
      await db
        .collection("userDiscussions")
        .doc(curDiscussionMember.userId)
        .collection("discussions")
        .add(newUserDiscussion);
    }
  }
};
