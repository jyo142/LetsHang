part of 'user_event_incomplete_status_bloc.dart';

enum UserEventIncompleteStatusStateStatus {
  initial,
  loading,
  retrievedUserIncompleteStatus,
  error
}

class UserEventIncompleteStatusState extends Equatable {
  final UserEventIncompleteStatusStateStatus
      userEventIncompleteStatusStateStatus;
  final int incompleteResponsibilitiesCount;
  final int incompletePollCount;
  final bool hasIncomplete;

  const UserEventIncompleteStatusState({
    required this.userEventIncompleteStatusStateStatus,
    this.incompleteResponsibilitiesCount = 0,
    this.incompletePollCount = 0,
    this.hasIncomplete = false,
  });

  UserEventIncompleteStatusState copyWith({
    UserEventIncompleteStatusStateStatus? userEventIncompleteStatusStateStatus,
    int? incompleteResponsibilitiesCount,
    int? incompletePollCount,
    bool? hasIncomplete,
  }) {
    return UserEventIncompleteStatusState(
      userEventIncompleteStatusStateStatus:
          userEventIncompleteStatusStateStatus ??
              this.userEventIncompleteStatusStateStatus,
      incompleteResponsibilitiesCount: incompleteResponsibilitiesCount ??
          this.incompleteResponsibilitiesCount,
      incompletePollCount: incompletePollCount ?? this.incompletePollCount,
      hasIncomplete: hasIncomplete ?? this.hasIncomplete,
    );
  }

  @override
  List<Object?> get props => [
        userEventIncompleteStatusStateStatus,
        incompleteResponsibilitiesCount,
        incompletePollCount,
        hasIncomplete
      ];
}
