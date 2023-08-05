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
      String userEmail) async {
    QuerySnapshot pendingNotificationsSnapshot = await _firebaseFirestore
        .collection("notifications")
        .doc(userEmail)
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
  Future<void> removeNotificationForUser(
      String userEmail, String notificationId) async {
    await _firebaseFirestore
        .collection("notifications")
        .doc(userEmail)
        .collection("pendingNotifications")
        .doc(notificationId)
        .delete();
  }

  @override
  Future<NotificationsModel> addNotificationForUser(
      String userEmail, String notificationContent) async {
    NotificationsModel savingNotification = NotificationsModel(
        id: FirebaseFirestore.instance.collection('groups').doc().id,
        userEmail: userEmail,
        content: notificationContent,
        createdDate: DateTime.now());
    await _firebaseFirestore
        .collection('notifications')
        .doc(userEmail)
        .collection("pendingNotifications")
        .doc(savingNotification.id)
        .set(savingNotification.toDocument());
    return savingNotification;
  }
}
