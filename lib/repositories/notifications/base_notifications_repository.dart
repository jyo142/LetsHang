import 'package:letshang/models/invite.dart';
import 'package:letshang/models/notifications_model.dart';

abstract class BaseNotificationsRepository {
  Future<List<NotificationsModel>> getPendingNotificationsForUser(
      String userId);
  Future<NotificationsModel?> getNotificationDetails(
      String userId, String notificationId);
  Future<NotificationsModel> addNotificationForUser(
      String userId, String notificationContent);
  Future<void> markNotificationAsReadForUser(
      String userId, String notificationId);
  Future<void> removeNotificationForUser(String userId, String notificationId);
  Future<void> removeEntityNotificationForUser(
      String userId, String entityId, InviteType entityType);
}
