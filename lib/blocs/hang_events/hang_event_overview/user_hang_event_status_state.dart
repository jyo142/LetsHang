part of 'user_hang_event_status_bloc.dart';

enum UserEventStatusStateStatus {
  initial,
  loading,
  loadingUserEventTitle,
  retrievedUserIncompleteStatus,
  error
}

class UserEventStatusState extends Equatable {
  final UserEventStatusStateStatus userEventStatusStateStatus;
  final InviteTitle userEventTitle;
  final int incompleteResponsibilitiesCount;
  final int incompletePollCount;
  final int eventParticipantsCount;
  final bool hasIncomplete;

  const UserEventStatusState({
    required this.userEventStatusStateStatus,
    this.userEventTitle = InviteTitle.user,
    this.incompleteResponsibilitiesCount = 0,
    this.incompletePollCount = 0,
    this.eventParticipantsCount = 0,
    this.hasIncomplete = false,
  });

  UserEventStatusState copyWith({
    UserEventStatusStateStatus? userEventStatusStateStatus,
    InviteTitle? userEventTitle,
    int? incompleteResponsibilitiesCount,
    int? incompletePollCount,
    int? eventParticipantsCount,
    bool? hasIncomplete,
  }) {
    return UserEventStatusState(
      userEventStatusStateStatus:
          userEventStatusStateStatus ?? this.userEventStatusStateStatus,
      userEventTitle: userEventTitle ?? this.userEventTitle,
      incompleteResponsibilitiesCount: incompleteResponsibilitiesCount ??
          this.incompleteResponsibilitiesCount,
      incompletePollCount: incompletePollCount ?? this.incompletePollCount,
      eventParticipantsCount:
          eventParticipantsCount ?? this.eventParticipantsCount,
      hasIncomplete: hasIncomplete ?? this.hasIncomplete,
    );
  }

  @override
  List<Object?> get props => [
        userEventStatusStateStatus,
        userEventTitle,
        incompleteResponsibilitiesCount,
        incompletePollCount,
        eventParticipantsCount,
        hasIncomplete
      ];
}
