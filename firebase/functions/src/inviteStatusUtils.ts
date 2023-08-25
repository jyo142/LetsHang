import { QueryDocumentSnapshot } from "firebase-functions/v2/firestore";

export const getStatusTitleDescription = (
  inviteType: "Group" | "Event",
  newUserStatus: string,
  curUserSnapshot: QueryDocumentSnapshot,
  inviteTypeName: string,
) => {
  switch (newUserStatus) {
    case "accepted":
      return {
        title: `${inviteType} invitation accepted`,
        description: `${curUserSnapshot.get(
          "name",
        )} has accepted your invite to ${inviteType.toLowerCase()} : ${inviteTypeName}`,
      };
    case "rejected":
      return {
        title: `${inviteType} invitation rejected`,
        description: `${curUserSnapshot.get(
          "name",
        )} has rejected your invite to ${inviteType.toLowerCase()} : ${inviteTypeName}`,
      };
    default:
      // tenative
      return {
        title: `${inviteType} invitation tentative`,
        description: `${curUserSnapshot.get(
          "name",
        )} has responded as tentative to your invite to ${inviteType.toLowerCase()} : ${inviteTypeName}`,
      };
  }
};
