part of 'user_hang_event_title_bloc.dart';

@immutable
abstract class UserHangEventTitleEvent extends Equatable {
  const UserHangEventTitleEvent();

  @override
  List<Object> get props => [];
}

class GetUserEventTitle extends UserHangEventTitleEvent {
  final String eventId;
  final String userId;
  const GetUserEventTitle({required this.eventId, required this.userId});

  @override
  List<Object> get props => [eventId, userId];
}
