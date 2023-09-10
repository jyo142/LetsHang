import 'package:letshang/models/notifications_model.dart';

abstract class BaseNotificationsRepository {
  Future<List<NotificationsModel>> getPendingNotificationsForUser(
      String userEmail);
  Future<NotificationsModel> addNotificationForUser(
      String userEmail, String notificationContent);
  Future<void> markNotificationAsReadForUser(
      String userEmail, String notificationId);
  Future<void> removeNotificationForUser(
      String userEmail, String notificationId);
}
