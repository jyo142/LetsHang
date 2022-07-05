import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

export const onGroupUpdate = functions.firestore
    .document("groups/{groupId}")
    .onUpdate(async (snap) => {
      const newValue = snap.after.data();
      const newGroupMembers = newValue.memberIds;
      const prevValue = snap.before.data();
      const prevGroupMembers = prevValue.memberIds;
      console.log(`running after updating group : ${newValue.name}`);

      const toAddMembers = findMemberDifferences(
          prevGroupMembers,
          newGroupMembers
      );
      const toDeleteMembers = findMemberDifferences(
          newGroupMembers,
          prevGroupMembers
      );

      const batch = db.batch();

      await Promise.all(
          toAddMembers.map(async (member) => {
            const snapshot = await db
                .collection("users")
                .where("userName", "==", member)
                .get();
            if (!snapshot.empty) {
              console.log(`adding group ${newValue.name} for user ${member}`);
              batch.update(snapshot.docs[0].ref, {
                groups: admin.firestore.FieldValue.arrayUnion(newValue.name),
              });
            }
          })
      );

      await Promise.all(
          toDeleteMembers.map(async (member) => {
            const snapshot = await db
                .collection("users")
                .where("userName", "==", member)
                .get();
            if (!snapshot.empty) {
              console.log(`removing group ${newValue.name} for user ${member}`);
              batch.update(snapshot.docs[0].ref, {
                groups: admin.firestore.FieldValue.arrayRemove(newValue.name),
              });
            }
          })
      );
      await batch.commit();
    });

export const onGroupCreate = functions.firestore
    .document("groups/{groupId}")
    .onCreate(async (snap) => {
      const newValue = snap.data();
      const newGroupMembers: string[] = newValue.memberIds;
      console.log(`running after creating group : ${newValue.name}`);

      const batch = db.batch();

      await Promise.all(
          newGroupMembers.map(async (member) => {
            const snapshot = await db
                .collection("users")
                .where("userName", "==", member)
                .get();
            if (!snapshot.empty) {
              console.log(`adding group ${newValue.name} for user ${member}`);
              batch.update(snapshot.docs[0].ref, {
                groups: admin.firestore.FieldValue.arrayUnion(newValue.name),
              });
            }
          })
      );

      await batch.commit();
    });

export const onGroupDelete = functions.firestore
    .document("groups/{groupId}")
    .onDelete(async (snap) => {
      const deletedGroup = snap.data();
      const groupMembers: string[] = deletedGroup.memberIds;
      console.log(`running after deleting group : ${deletedGroup.name}`);

      const batch = db.batch();

      await Promise.all(
          groupMembers.map(async (member) => {
            const snapshot = await db
                .collection("users")
                .where("userName", "==", member)
                .get();
            if (!snapshot.empty) {
              console.log(`removing group ${deletedGroup.name} for user ${member}`);
              batch.update(snapshot.docs[0].ref, {
                groups: admin.firestore.FieldValue.arrayRemove(deletedGroup.name),
              });
            }
          })
      );

      await batch.commit();
    });
/**
 * finds members that are not in the secondMembers but are in the firstMembers
 * @param firstMembers first members
 * @param secondMembers second members
 * @return array of members that are not in the secondMembers but
 * are in the firstMembers
 */
const findMemberDifferences = (
    firstMembers: string[],
    secondMembers: string[]
) => {
  const secondMembersSet: Set<string> = new Set(secondMembers);
  const retVal: string[] = [];

  for (const member of firstMembers) {
    if (secondMembersSet.has(member)) {
      retVal.push(member);
    }
  }
  return retVal;
};
