part of 'notifications_bloc.dart';

enum NotificationStateStatus {
  initial,
  pendingUserNotificationsLoading,
  pendingUserNotificationsRetrieved,
  loadingNotificationDetails,
  notificationDetailsRetrieved,
  error
}

class NotificationsState extends Equatable {
  final List<NotificationsModel> pendingNotifications;
  final NotificationsModel? currentNotificationDetails;
  final String? errorMessage;
  final NotificationStateStatus notificationStateStatus;

  const NotificationsState(
      {this.pendingNotifications = const [],
      this.currentNotificationDetails,
      required this.notificationStateStatus,
      this.errorMessage});

  NotificationsState copyWith(
      {NotificationStateStatus? notificationStateStatus,
      NotificationsModel? currentNotificationDetails,
      List<NotificationsModel>? pendingNotifications,
      String? errorMessage}) {
    return NotificationsState(
        notificationStateStatus:
            notificationStateStatus ?? this.notificationStateStatus,
        currentNotificationDetails:
            currentNotificationDetails ?? this.currentNotificationDetails,
        pendingNotifications: pendingNotifications ?? this.pendingNotifications,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        notificationStateStatus,
        currentNotificationDetails,
        pendingNotifications,
        errorMessage
      ];
}
