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
  }

  Future<HangEventResponsibilitiesState> _mapLoadEventResponsibilities(
      String eventId) async {
    try {
      List<HangEventResponsibility>? retrievedEventResponsibilities =
          await _responsibilitiesRepository.getEventResponsibilities(eventId);

      return state.copyWith(
          eventResponsibilitiesStateStatus: HangEventResponsibilitiesStateStatus
              .retrievedEventResponsibilities,
          eventResponsibilities: retrievedEventResponsibilities);
    } catch (_) {
      return state.copyWith(
          eventResponsibilitiesStateStatus:
              HangEventResponsibilitiesStateStatus.error,
          errorMessage: 'Unable to get discussions for user.');
    }
  }
}
