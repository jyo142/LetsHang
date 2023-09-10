part of 'notifications_bloc.dart';

enum NotificationStateStatus {
  initial,
  pendingUserNotificationsLoading,
  pendingUserNotificationsRetrieved,
  error
}

class NotificationsState extends Equatable {
  final List<NotificationsModel> pendingNotifications;
  final String? errorMessage;
  final NotificationStateStatus notificationStateStatus;

  NotificationsState(
      {this.pendingNotifications = const [],
      required this.notificationStateStatus,
      this.errorMessage});

  NotificationsState copyWith(
      {NotificationStateStatus? notificationStateStatus,
      List<NotificationsModel>? pendingNotifications,
      String? errorMessage}) {
    return NotificationsState(
        notificationStateStatus:
            notificationStateStatus ?? this.notificationStateStatus,
        pendingNotifications: pendingNotifications ?? this.pendingNotifications,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [notificationStateStatus, pendingNotifications, errorMessage];
}
