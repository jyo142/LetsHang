import 'package:letshang/models/hang_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/models/notifications_model.dart';

abstract class BaseNotificationsRepository {
  Future<List<NotificationsModel>> getPendingNotificationsForUser(
      String userEmail);
  Future<void> removeNotificationForUser(
      String userEmail, String notificationId);
}
