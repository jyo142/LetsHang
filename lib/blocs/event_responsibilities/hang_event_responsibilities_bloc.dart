import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/repositories/responsibilities/base_responsibilities_repository.dart';
import 'package:letshang/repositories/responsibilities/responsibilities_repository.dart';

part 'hang_event_responsibilities_state.dart';
part 'hang_event_responsibilities_event.dart';

class HangEventResponsibilitiesBloc extends Bloc<HangEventResponsibilitiesEvent,
    HangEventResponsibilitiesState> {
  final BaseResponsibilitiesRepository _responsibilitiesRepository;
  // constructor
  HangEventResponsibilitiesBloc()
      : _responsibilitiesRepository = ResponsibilitiesRepository(),
        super(HangEventResponsibilitiesState(
            eventResponsibilitiesStateStatus:
                HangEventResponsibilitiesStateStatus.initial)) {
    on<LoadEventResponsibilities>((event, emit) async {
      emit(state.copyWith(
          eventResponsibilitiesStateStatus: HangEventResponsibilitiesStateStatus
              .loadingEventResponsibilities));
      emit(await _mapLoadEventResponsibilities(event.eventId));
    });
    on<LoadUserEventResponsibilities>((event, emit) async {
      emit(state.copyWith(
          eventResponsibilitiesStateStatus: HangEventResponsibilitiesStateStatus
              .loadingEventResponsibilities));
      emit(
          await _mapLoadUserEventResponsibilities(event.eventId, event.userId));
    });

    on<CompleteEventResponsibility>((event, emit) async {
      emit(state.copyWith(
          eventResponsibilitiesStateStatus: HangEventResponsibilitiesStateStatus
              .loadingCompleteResponsibility));
      emit(await _mapCompleteResponsibility(
          event.eventId, event.eventResponsibility));
    });
  }

  Future<HangEventResponsibilitiesState> _mapLoadEventResponsibilities(
      String eventId) async {
    try {
      List<HangEventResponsibility>? retrievedActiveEventResponsibilities =
          await _responsibilitiesRepository
              .getActiveEventResponsibilities(eventId);
      List<HangEventResponsibility>? retrievedCompletedEventResponsibilities =
          await _responsibilitiesRepository
              .getCompletedEventResponsibilities(eventId);
      return state.copyWith(
          eventResponsibilitiesStateStatus: HangEventResponsibilitiesStateStatus
              .retrievedEventResponsibilities,
          activeEventResponsibilities: retrievedActiveEventResponsibilities,
          completedEventResponsibilities:
              retrievedCompletedEventResponsibilities);
    } catch (_) {
      return state.copyWith(
          eventResponsibilitiesStateStatus:
              HangEventResponsibilitiesStateStatus.error,
          errorMessage: 'Unable to get responsibilities for event.');
    }
  }

  Future<HangEventResponsibilitiesState> _mapLoadUserEventResponsibilities(
      String eventId, String userId) async {
    try {
      List<HangEventResponsibility>? retrievedUserEventResponsibilities =
          await _responsibilitiesRepository.getUserResponsibilitiesForEvent(
              eventId, userId);
      return state
          .withUserResponsibilityData(retrievedUserEventResponsibilities);
    } catch (_) {
      return state.copyWith(
          eventResponsibilitiesStateStatus:
              HangEventResponsibilitiesStateStatus.error,
          errorMessage: 'Unable to get responsibilities for event.');
    }
  }

  Future<HangEventResponsibilitiesState> _mapCompleteResponsibility(
      String eventId, HangEventResponsibility eventResponsibility) async {
    try {
      await _responsibilitiesRepository.completeEventResponsibility(
          eventId, eventResponsibility);

      return state.copyWith(
        eventResponsibilitiesStateStatus: HangEventResponsibilitiesStateStatus
            .successfullyCompletedResponsibility,
      );
    } catch (_) {
      return state.copyWith(
          eventResponsibilitiesStateStatus:
              HangEventResponsibilitiesStateStatus.error,
          errorMessage: 'Unable to complete event responsibility.');
    }
  }
}
