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
        super(const NotificationsState());

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    // events to do with the group metadata
    if (event is LoadPendingNotifications) {
      yield* _mapPendingNotificationsState(event.userEmail);
    }
  }

  Stream<NotificationsState> _mapPendingNotificationsState(
      String userEmail) async* {
    try {
      List<NotificationsModel> allPendingNotifications =
          await _notificationsRepository
              .getPendingNotificationsForUser(userEmail);

      yield PendingUserNotificationsRetrieved(
          pendingNotifications: allPendingNotifications);
    } catch (_) {
      yield const PendingUserNotificationsError(
          errorMessage: 'Unable to get notifications for user.');
    }
  }
}
