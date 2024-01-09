part of 'hang_event_responsibilities_bloc.dart';

enum HangEventResponsibilitiesStateStatus {
  initial,
  loadingEventResponsibilities,
  retrievedEventResponsibilities,
  loadingCompleteResponsibility,
  successfullyCompletedResponsibility,
  error
}

class HangEventResponsibilitiesState extends Equatable {
  final HangEventResponsibilitiesStateStatus eventResponsibilitiesStateStatus;
  final List<HangEventResponsibility>? activeEventResponsibilities;
  final List<HangEventResponsibility>? completedEventResponsibilities;
  final int? activeUserEventResponsibilities;
  final int? completedUserEventResponsibilities;
  final String? errorMessage;

  const HangEventResponsibilitiesState(
      {required this.eventResponsibilitiesStateStatus,
      this.activeEventResponsibilities,
      this.completedEventResponsibilities,
      this.activeUserEventResponsibilities,
      this.completedUserEventResponsibilities,
      this.errorMessage});

  HangEventResponsibilitiesState copyWith(
      {HangEventResponsibilitiesStateStatus? eventResponsibilitiesStateStatus,
      List<HangEventResponsibility>? activeEventResponsibilities,
      List<HangEventResponsibility>? completedEventResponsibilities,
      int? activeUserEventResponsibilities,
      int? completedUserEventResponsibilities,
      String? errorMessage}) {
    return HangEventResponsibilitiesState(
        eventResponsibilitiesStateStatus: eventResponsibilitiesStateStatus ??
            this.eventResponsibilitiesStateStatus,
        activeEventResponsibilities:
            activeEventResponsibilities ?? this.activeEventResponsibilities,
        completedEventResponsibilities: completedEventResponsibilities ??
            this.completedEventResponsibilities,
        activeUserEventResponsibilities: activeUserEventResponsibilities ??
            this.activeUserEventResponsibilities,
        completedUserEventResponsibilities:
            completedUserEventResponsibilities ??
                this.completedUserEventResponsibilities,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  HangEventResponsibilitiesState withUserResponsibilityData(
      List<HangEventResponsibility> userEventResponsibilities) {
    int numActive = 0;
    int numCompleted = 0;

    for (var element in userEventResponsibilities) {
      if (element.completedDate != null) {
        numCompleted += 1;
      } else {
        numActive += 1;
      }
    }
    return copyWith(
        activeUserEventResponsibilities: numActive,
        completedUserEventResponsibilities: numCompleted,
        eventResponsibilitiesStateStatus: HangEventResponsibilitiesStateStatus
            .retrievedEventResponsibilities);
  }

  @override
  List<Object?> get props => [
        eventResponsibilitiesStateStatus,
        activeEventResponsibilities,
        completedEventResponsibilities,
        activeUserEventResponsibilities,
        completedUserEventResponsibilities,
        errorMessage,
      ];
}
