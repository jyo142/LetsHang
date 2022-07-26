import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const onGroupUpdate = functions.firestore
    .document("groups/{groupId}")
    .onUpdate(async (snap) => {
      const newValue = snap.after.data();
      const newGroupMembers = newValue.memberIds;
      const prevValue = snap.before.data();
      const prevGroupMembers = prevValue.memberIds;
      console.log(`running after updating group : ${newValue.name}`);
      console.log(prevGroupMembers);
      console.log(newGroupMembers);
      const toAddMembers = findNewMembers(prevGroupMembers, newGroupMembers);

      console.log(toAddMembers);
      await Promise.all(
          toAddMembers.map(async (member) => {
            const snapshot = await db
                .collection("users")
                .where("userName", "==", member)
                .get();
            if (!snapshot.empty) {
              const curUserSnapshot = snapshot.docs[0];
              console.log(
                  `sending notifiation to user ${curUserSnapshot.get("userName")}`
              );
              const payload = {
                notification: {
                  title: "New Group Invitation",
                  body: `Hello ${curUserSnapshot.get(
                      "name"
                  )}, you have been invited to the ${newValue.name} group`,
                  sound: "default",
                  badge: "1",
                },
              };
              await admin
                  .messaging()
                  .sendToDevice([curUserSnapshot.get("fcmToken")], payload);
            }
          })
      );
    });

// export const onGroupCreate = functions.firestore
//     .document("groups/{groupId}")
//     .onCreate(async (snap) => {
//       const newValue = snap.data();
//       const newGroupMembers: string[] = newValue.memberIds;
//       console.log(`running after creating group : ${newValue.name}`);

//       const batch = db.batch();

//       await Promise.all(
//           newGroupMembers.map(async (member) => {
//             const snapshot = await db
//                 .collection("users")
//                 .where("userName", "==", member)
//                 .get();
//             if (!snapshot.empty) {
//               console.log(`adding group ${newValue.name} for user ${member}`);
//               batch.update(snapshot.docs[0].ref, {
//                 groups: admin.firestore.FieldValue.arrayUnion(newValue.name),
//               });
//             }
//           })
//       );

//       await batch.commit();
//     });

// export const onGroupDelete = functions.firestore
//     .document("groups/{groupId}")
//     .onDelete(async (snap) => {
//       const deletedGroup = snap.data();
//       const groupMembers: string[] = deletedGroup.memberIds;
//       console.log(`running after deleting group : ${deletedGroup.name}`);

//       const batch = db.batch();

//       await Promise.all(
//           groupMembers.map(async (member) => {
//             const snapshot = await db
//                 .collection("users")
//                 .where("userName", "==", member)
//                 .get();
//             if (!snapshot.empty) {
//               console.log(`removing group ${deletedGroup.name} for user ${member}`);
//               batch.update(snapshot.docs[0].ref, {
//                 groups: admin.firestore.FieldValue.arrayRemove(deletedGroup.name),
//               });
//             }
//           })
//       );

//       await batch.commit();
//     });

/**
 * finds members that are not in the firstMembers but are in the secondMembers
 * @param firstMembers first members
 * @param secondMembers second members
 * @return array of members that are not in the firstMembers but are in the secondMembers
 */
const findNewMembers = (firstMembers: string[], secondMembers: string[]) => {
  const nonSecondMembers = secondMembers.filter(
      (mem) => !firstMembers.includes(mem)
  );
  return nonSecondMembers;
};
