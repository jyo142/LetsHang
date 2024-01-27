part of 'user_hang_event_status_bloc.dart';

enum UserEventStatusStateStatus {
  initial,
  loading,
  retrievedUserIncompleteStatus,
  error
}

class UserEventStatusState extends Equatable {
  final UserEventStatusStateStatus userEventStatusStateStatus;
  final int incompleteResponsibilitiesCount;
  final int incompletePollCount;
  final int eventParticipantsCount;
  final bool hasIncomplete;

  const UserEventStatusState({
    required this.userEventStatusStateStatus,
    this.incompleteResponsibilitiesCount = 0,
    this.incompletePollCount = 0,
    this.eventParticipantsCount = 0,
    this.hasIncomplete = false,
  });

  UserEventStatusState copyWith({
    UserEventStatusStateStatus? userEventStatusStateStatus,
    int? incompleteResponsibilitiesCount,
    int? incompletePollCount,
    int? eventParticipantsCount,
    bool? hasIncomplete,
  }) {
    return UserEventStatusState(
      userEventStatusStateStatus:
          userEventStatusStateStatus ?? this.userEventStatusStateStatus,
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
        incompleteResponsibilitiesCount,
        incompletePollCount,
        eventParticipantsCount,
        hasIncomplete
      ];
}
