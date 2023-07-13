part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadPendingNotifications extends NotificationsEvent {
  final String userEmail;

  const LoadPendingNotifications(this.userEmail);

  @override
  List<Object> get props => [userEmail];
}
