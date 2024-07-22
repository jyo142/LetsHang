part of 'user_hang_event_title_bloc.dart';

enum UserHangEventTitleStateStatus {
  initial,
  loading,
  retrievedUserEventTitle,
  error
}

class UserHangEventTitleState extends Equatable {
  final UserHangEventTitleStateStatus userHangEventTitleStateStatus;
  final InviteTitle userEventTitle;
  final String? errorMessage;
  const UserHangEventTitleState(
      {required this.userHangEventTitleStateStatus,
      this.userEventTitle = InviteTitle.user,
      this.errorMessage});

  UserHangEventTitleState copyWith(
      {UserHangEventTitleStateStatus? userHangEventTitleStateStatus,
      InviteTitle? userEventTitle,
      String? errorMessage}) {
    return UserHangEventTitleState(
        userHangEventTitleStateStatus:
            userHangEventTitleStateStatus ?? this.userHangEventTitleStateStatus,
        userEventTitle: userEventTitle ?? this.userEventTitle,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [userHangEventTitleStateStatus, userEventTitle, errorMessage];
}
