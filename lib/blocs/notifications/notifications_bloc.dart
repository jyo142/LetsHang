import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/repositories/notifications/notifications_repository.dart';
import 'package:equatable/equatable.dart';

part 'notifications_state.dart';
part 'notifications_event.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _notificationsRepository;
  // constructor
  NotificationsBloc()
      : _notificationsRepository = NotificationsRepository(),
        super(const NotificationsState()) {
    on<LoadPendingNotifications>((event, emit) async {
      emit(await _mapPendingNotificationsState(event.userEmail));
    });
  }

  Future<NotificationsState> _mapPendingNotificationsState(
      String userEmail) async {
    try {
      List<NotificationsModel> allPendingNotifications =
          await _notificationsRepository
              .getPendingNotificationsForUser(userEmail);

      return PendingUserNotificationsRetrieved(
          pendingNotifications: allPendingNotifications);
    } catch (_) {
      return const PendingUserNotificationsError(
          errorMessage: 'Unable to get notifications for user.');
    }
  }
}
