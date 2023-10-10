import 'package:letshang/models/notifications_model.dart';

abstract class BaseNotificationsRepository {
  Future<List<NotificationsModel>> getPendingNotificationsForUser(
      String userId);
  Future<NotificationsModel> addNotificationForUser(
      String userId, String notificationContent);
  Future<void> markNotificationAsReadForUser(
      String userId, String notificationId);
  Future<void> removeNotificationForUser(String userId, String notificationId);
}
