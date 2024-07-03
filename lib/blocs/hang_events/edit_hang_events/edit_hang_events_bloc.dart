import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/base_hang_event_repository.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'edit_hang_events_event.dart';
part 'edit_hang_events_state.dart';

class EditHangEventsBloc
    extends Bloc<EditHangEventsEvent, EditHangEventsState> {
  final BaseHangEventRepository _hangEventRepository;

  // constructor
  EditHangEventsBloc()
      : _hangEventRepository = HangEventRepository(),
        super(const EditHangEventsState(
            editHangEventsStateStatus: EditHangEventsStateStatus.initial)) {
    on<CancelIndividualEvent>((event, emit) async {
      emit(state.copyWith(
          editHangEventsStateStatus:
              EditHangEventsStateStatus.cancellingEvent));
      emit(await _mapCancelIndividualEventToState(eventId: event.eventId));
    });
  }
  Future<EditHangEventsState> _mapCancelIndividualEventToState(
      {required String eventId}) async {
    try {
      await _hangEventRepository.cancelHangEvent(eventId);
      return state.copyWith(
        editHangEventsStateStatus:
            EditHangEventsStateStatus.eventCancelledSuccessfully,
      );
    } catch (e) {
      return state.copyWith(
        editHangEventsStateStatus: EditHangEventsStateStatus.error,
      );
    }
  }
}
