part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class PendingUserNotificationsLoading extends NotificationsState {}

class PendingUserNotificationsRetrieved extends NotificationsState {
  late final List<NotificationsModel> pendingNotifications;
  PendingUserNotificationsRetrieved({required this.pendingNotifications}) {
    final dateNow = DateTime.now();
    // past events are when the current date is after both the start and end date of the event
  }

  @override
  List<Object> get props => [pendingNotifications];
}

class PendingUserNotificationsError extends NotificationsState {
  final String errorMessage;
  const PendingUserNotificationsError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
