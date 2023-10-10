import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/user_settings/user_settings_bloc.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/repositories/notifications/base_notifications_repository.dart';
import 'package:letshang/repositories/notifications/notifications_repository.dart';
import 'package:equatable/equatable.dart';

part 'notifications_state.dart';
part 'notifications_event.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final BaseNotificationsRepository _notificationsRepository;
  // constructor
  NotificationsBloc()
      : _notificationsRepository = NotificationsRepository(),
        super(NotificationsState(
            notificationStateStatus: NotificationStateStatus.initial)) {
    on<LoadPendingNotifications>((event, emit) async {
      emit(await _mapPendingNotificationsState(event.userId));
    });
    on<MarkNotificationAsRead>((event, emit) async {
      await _markNotificationAsRead(event.userId, event.notificationId);
      emit(state);
    });
  }

  Future<NotificationsState> _mapPendingNotificationsState(
      String userId) async {
    try {
      List<NotificationsModel> allPendingNotifications =
          await _notificationsRepository.getPendingNotificationsForUser(userId);

      return state.copyWith(
          notificationStateStatus:
              NotificationStateStatus.pendingUserNotificationsRetrieved,
          pendingNotifications: allPendingNotifications);
    } catch (_) {
      return state.copyWith(
          notificationStateStatus: NotificationStateStatus.error,
          errorMessage: 'Unable to get notifications for user.');
    }
  }

  Future _markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _notificationsRepository.markNotificationAsReadForUser(
          userId, notificationId);
    } catch (_) {
      // log error marking notification as read
      return state.copyWith(
          notificationStateStatus: NotificationStateStatus.error,
          errorMessage: 'Unable to mark notification as read');
    }
  }
}
