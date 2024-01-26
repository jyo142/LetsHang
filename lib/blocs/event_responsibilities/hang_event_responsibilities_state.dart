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
  final String? errorMessage;

  const HangEventResponsibilitiesState(
      {required this.eventResponsibilitiesStateStatus,
      this.activeEventResponsibilities,
      this.completedEventResponsibilities,
      this.errorMessage});

  HangEventResponsibilitiesState copyWith(
      {HangEventResponsibilitiesStateStatus? eventResponsibilitiesStateStatus,
      List<HangEventResponsibility>? activeEventResponsibilities,
      List<HangEventResponsibility>? completedEventResponsibilities,
      String? errorMessage}) {
    return HangEventResponsibilitiesState(
        eventResponsibilitiesStateStatus: eventResponsibilitiesStateStatus ??
            this.eventResponsibilitiesStateStatus,
        activeEventResponsibilities:
            activeEventResponsibilities ?? this.activeEventResponsibilities,
        completedEventResponsibilities: completedEventResponsibilities ??
            this.completedEventResponsibilities,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        eventResponsibilitiesStateStatus,
        activeEventResponsibilities,
        completedEventResponsibilities,
        errorMessage,
      ];
}
