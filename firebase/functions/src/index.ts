import * as admin from "firebase-admin";

admin.initializeApp();

export const db = admin.firestore();

export * as eventFunctions from "./eventFunctions";
export * as groupFunctions from "./groupFunctions";
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript


// export const onGroupUpdate = functions.firestore
//     .document("groups/{groupId}")
//     .onUpdate(async (snap) => {
//       const newValue = snap.after.data();
//       const newGroupMembers = newValue.memberIds;
//       const prevValue = snap.before.data();
//       const prevGroupMembers = prevValue.memberIds;
//       console.log(`running after updating group : ${newValue.name}`);
//       console.log(prevGroupMembers);
//       console.log(newGroupMembers);
//       const toAddMembers = findNewMembers(prevGroupMembers, newGroupMembers);

//       console.log(toAddMembers);
//       await Promise.all(
//           toAddMembers.map(async (member) => {
//             const snapshot = await db
//                 .collection("users")
//                 .where("userName", "==", member)
//                 .get();
//             if (!snapshot.empty) {
//               const curUserSnapshot = snapshot.docs[0];
//               console.log(
//                   `sending notifiation to user ${curUserSnapshot.get("userName")}`
//               );
//               const payload = {
//                 notification: {
//                   title: "New Group Invitation",
//                   body: `Hello ${curUserSnapshot.get(
//                       "name"
//                   )}, you have been invited to the ${newValue.name} group`,
//                   sound: "default",
//                   badge: "1",
//                 },
//               };
//               await admin
//                   .messaging()
//                   .sendToDevice([curUserSnapshot.get("fcmToken")], payload);
//             }
//           })
//       );
//     });

// export const onEventUpdate = functions.firestore
//     .document("hangEvents/{eventId}/invites/{inviteId}")
//     .onUpdate(async (snap, context) => {
//       const newValue = snap.after.data();
//       const newEventUserInvites = newValue.userInvites;
//       console.log("new");
//       console.log(newEventUserInvites);
//       const prevValue = snap.before.data();
//       const prevEventUserInvites = prevValue.userInvites;

//       console.log("prev");
//       console.log(prevEventUserInvites);

//       const eventDocSnapshot = await db
//           .collection("hangEvents")
//           .doc(context.eventId)
//           .get();

//       console.log(
//           `running after updating event : ${eventDocSnapshot.get("name")}`
//       );

//       const toAddUserNames = findNewMembers(
//           prevEventUserInvites.map((ui: any) => ui.userName),
//           newEventUserInvites.map((ui: any) => ui.userName)
//       );

//       const batch = db.batch();

//       await Promise.all(
//           toAddUserNames.map(async (u) => {
//             const snapshot = await db
//                 .collection("userInvites")
//                 .where("userName", "==", u)
//                 .get();
//             if (!snapshot.empty) {
//               // console.log(
//               //   `adding event ${eventDocSnapshot.get("name")} for user ${u}`
//               // );
//               // batch.update(snapshot.docs[0].ref, {
//               //   groups: admin.firestore.FieldValue.arrayUnion(newValue.name),
//               // });
//             } else {
//               const newSnapshotRef = db.collection("userInvites").doc(u);
//               batch.set(newSnapshotRef, {
//                 invites: [
//                   {
//                     user: u,
//                     status: "pending",
//                     type: "event",
//                   },
//                 ],
//               });
//             }
//           })
//       );
//     });

// export const onEventCreate = functions.firestore
//     .document("hangEvents/{eventId}/invites/{inviteId}")
//     .onCreate(async (snap, context) => {
//       const newValue = snap.data();
//       const newEventUserInvites = newValue.userInvites;

//       const eventDocSnapshot = await db
//           .collection("hangEvents")
//           .doc(context.params.eventId)
//           .get();

//       console.log(eventDocSnapshot);
//       console.log(
//           `running after creating event : ${eventDocSnapshot.get("name")}`
//       );

//       const batch = db.batch();

//       await Promise.all(
//           newEventUserInvites.map(async (ui: any) => {
//             const eventInviteCollection = db
//                 .collection("userInvites")
//                 .doc(ui.user.userName)
//                 .collection("eventInvites")
//                 .doc("events");
//             const eventInviteDocumentSnap = await eventInviteCollection.get();

//             console.log(eventDocSnapshot.get("eventOwner"));
//             const eventInviteToAdd = {
//               event: {
//                 id: eventDocSnapshot.id,
//                 eventName: eventDocSnapshot.get("eventName"),
//                 eventDescription: eventDocSnapshot.get("eventDescription"),
//                 eventStartDate: eventDocSnapshot.get("eventStartDate"),
//                 eventEndDate: eventDocSnapshot.get("eventEndDate"),
//                 eventOwner: eventDocSnapshot.get("eventOwner"),
//               },
//               status: "pending",
//               type: "event",
//             };

//             let retValEvents = [];
//             if (eventInviteDocumentSnap.exists) {
//               retValEvents = eventInviteDocumentSnap.get("eventInvites");
//               if (
//                 !retValEvents.some(
//                     (ei: any) => ei.event.id === context.params.eventId
//                 )
//               ) {
//                 console.log("didnt find the event");
//                 retValEvents.push(eventInviteToAdd);
//               }
//             } else {
//               retValEvents.push(eventInviteToAdd);
//             }
//             batch.set(eventInviteCollection, {
//               eventInvites: retValEvents,
//             });
//           })
//       );
//       await batch.commit();
//     });

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

// /**
//  * finds members that are not in the firstMembers but are in the secondMembers
//  * @param firstMembers first members
//  * @param secondMembers second members
//  * @return array of members that are not in the firstMembers but are in the secondMembers
//  */
// const findNewMembers = (firstMembers: string[], secondMembers: string[]) => {
//   const nonSecondMembers = secondMembers.filter(
//       (mem) => !firstMembers.includes(mem)
//   );
//   return nonSecondMembers;
// };
