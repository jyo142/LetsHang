part of 'user_event_incomplete_status_bloc.dart';

@immutable
abstract class UserEventIncompleteStatusEvent extends Equatable {
  const UserEventIncompleteStatusEvent();

  @override
  List<Object> get props => [];
}

class GetUserEventIncompleteStatus extends UserEventIncompleteStatusEvent {
  final String eventId;
  final String userId;
  const GetUserEventIncompleteStatus(
      {required this.eventId, required this.userId});

  @override
  List<Object> get props => [eventId, userId];
}
