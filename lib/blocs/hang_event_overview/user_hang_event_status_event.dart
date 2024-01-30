part of 'user_hang_event_status_bloc.dart';

@immutable
abstract class UserHangEventStatusEvent extends Equatable {
  const UserHangEventStatusEvent();

  @override
  List<Object> get props => [];
}

class GetUserEventStatus extends UserHangEventStatusEvent {
  final String eventId;
  final String userId;
  const GetUserEventStatus({required this.eventId, required this.userId});

  @override
  List<Object> get props => [eventId, userId];
}

class UpdateUserEventPollStatus extends UserHangEventStatusEvent {
  final String eventId;
  final String userId;
  const UpdateUserEventPollStatus(
      {required this.eventId, required this.userId});

  @override
  List<Object> get props => [eventId, userId];
}
