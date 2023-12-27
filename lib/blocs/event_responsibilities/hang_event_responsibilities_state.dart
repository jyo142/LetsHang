part of 'hang_event_responsibilities_bloc.dart';

enum HangEventResponsibilitiesStateStatus {
  initial,
  loadingEventResponsibilities,
  retrievedEventResponsibilities,
  error
}

class HangEventResponsibilitiesState extends Equatable {
  final HangEventResponsibilitiesStateStatus eventResponsibilitiesStateStatus;
  final List<HangEventResponsibility>? eventResponsibilities;
  final String? errorMessage;

  HangEventResponsibilitiesState(
      {required this.eventResponsibilitiesStateStatus,
      this.eventResponsibilities,
      this.errorMessage});

  HangEventResponsibilitiesState copyWith(
      {HangEventResponsibilitiesStateStatus? eventResponsibilitiesStateStatus,
      List<HangEventResponsibility>? eventResponsibilities,
      String? errorMessage}) {
    return HangEventResponsibilitiesState(
        eventResponsibilitiesStateStatus: eventResponsibilitiesStateStatus ??
            this.eventResponsibilitiesStateStatus,
        eventResponsibilities:
            eventResponsibilities ?? this.eventResponsibilities,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [eventResponsibilitiesStateStatus, eventResponsibilities, errorMessage];
}
