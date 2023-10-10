part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadPendingNotifications extends NotificationsEvent {
  final String userId;

  const LoadPendingNotifications(this.userId);

  @override
  List<Object> get props => [userId];
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String userId;
  final String notificationId;

  const MarkNotificationAsRead(this.userId, this.notificationId);

  @override
  List<Object> get props => [notificationId];
}
