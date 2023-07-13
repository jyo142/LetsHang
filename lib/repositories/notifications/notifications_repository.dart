import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/repositories/notifications/base_notifications_repository.dart';
import 'package:letshang/repositories/user/base_user_repository.dart';

class NotificationsRepository extends BaseNotificationsRepository {
  final FirebaseFirestore _firebaseFirestore;

  NotificationsRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<NotificationsModel>> getPendingNotificationsForUser(
      String userEmail) async {
    DocumentSnapshot notificationDocSnapshot = await _firebaseFirestore
        .collection('notifications')
        .doc(userEmail)
        .get();

    final pendingInvitesSnap =
        List.of(notificationDocSnapshot["pendingNotifications"]);
    return List.of(
        pendingInvitesSnap.map((pis) => NotificationsModel.fromMap(pis)));
  }
}
