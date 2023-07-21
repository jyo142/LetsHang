import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/repositories/notifications/base_notifications_repository.dart';

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

    final allDocSnapshots =
        pendingNotificationsSnapshot.docs.map((doc) => doc.data()).toList();

    List<NotificationsModel> allPendingNotifications =
        allDocSnapshots.map((doc) => NotificationsModel.fromMap(doc)).toList();

    return allPendingNotifications;
  }
}
