import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/repositories/notifications/base_notifications_repository.dart';
import 'package:letshang/utils/firebase_utils.dart';

class NotificationsRepository extends BaseNotificationsRepository {
  final FirebaseFirestore _firebaseFirestore;

  NotificationsRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<NotificationsModel>> getPendingNotificationsForUser(
      String userId) async {
    QuerySnapshot pendingNotificationsSnapshot = await _firebaseFirestore
        .collection("notifications")
        .doc(userId)
        .collection("pendingNotifications")
        .get();

    final allDocSnapshots = pendingNotificationsSnapshot.docs
        .map((doc) => doc.getDocDataWithId())
        .toList();

    List<NotificationsModel> allPendingNotifications =
        allDocSnapshots.map((doc) => NotificationsModel.fromMap(doc)).toList();

    return allPendingNotifications;
  }

  @override
  Future<NotificationsModel?> getNotificationDetails(
      String userId, String notificationId) async {
    DocumentSnapshot docSnapshot = await _firebaseFirestore
        .collection('notifications')
        .doc(userId)
        .collection("pendingNotifications")
        .doc(notificationId)
        .get();
    if (docSnapshot.exists) {
      return NotificationsModel.fromSnapshot(docSnapshot);
    }
    return null;
  }

  @override
  Future<void> removeNotificationForUser(
      String userId, String notificationId) async {
    await _firebaseFirestore
        .collection("notifications")
        .doc(userId)
        .collection("pendingNotifications")
        .doc(notificationId)
        .delete();
  }

  @override
  Future<NotificationsModel> addNotificationForUser(
      String userId, String notificationContent) async {
    NotificationsModel savingNotification = NotificationsModel(
        id: FirebaseFirestore.instance.collection('groups').doc().id,
        userId: userId,
        content: notificationContent,
        createdDate: DateTime.now());
    await _firebaseFirestore
        .collection('notifications')
        .doc(userId)
        .collection("pendingNotifications")
        .doc(savingNotification.id)
        .set(savingNotification.toDocument());
    return savingNotification;
  }

  @override
  Future<void> markNotificationAsReadForUser(
      String userId, String notificationId) async {
    // move the notifcation from pending collection to read collection
    DocumentReference notificationReference = _firebaseFirestore
        .collection("notifications")
        .doc(userId)
        .collection("pendingNotifications")
        .doc(notificationId);
    DocumentSnapshot notificationSnap = await notificationReference.get();

    if (notificationSnap.exists) {
      NotificationsModel currentNotification =
          NotificationsModel.fromSnapshot(notificationSnap);

      notificationReference.delete();

      await _firebaseFirestore
          .collection('notifications')
          .doc(userId)
          .collection("readNotifications")
          .doc(notificationId)
          .set(currentNotification.toDocument());
    }
  }
}
