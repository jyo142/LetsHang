import 'package:bloc/bloc.dart';
import 'package:letshang/models/events/hang_event_responsibility.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/repositories/responsibilities/base_responsibilities_repository.dart';
import 'package:letshang/repositories/responsibilities/responsibilities_repository.dart';

part 'add_event_responsibility_state.dart';
part 'add_event_responsibility_event.dart';

class AddEventResponsibilityBloc
    extends Bloc<AddEventResponsibilityEvent, AddEventResponsibilityState> {
  final BaseResponsibilitiesRepository _responsibilitiesRepository;
  // constructor
  AddEventResponsibilityBloc()
      : _responsibilitiesRepository = ResponsibilitiesRepository(),
        super(const AddEventResponsibilityState(
            addEventResponsibilityStateStatus:
                AddEventResponsibilityStateStatus.initial)) {
    on<ResponsibilityUserChanged>((event, emit) async {
      emit(state.copyWith(responsibilityUser: event.responsibilityUser));
    });
    on<ResponsibilityContentChanged>((event, emit) async {
      emit(state.copyWith(responsibilityContent: event.responsibilityContent));
    });
    on<AddResponsibility>((event, emit) async {
      emit(state.copyWith(
          addEventResponsibilityStateStatus:
              AddEventResponsibilityStateStatus.addingEventResponsibility));
      emit(await _mapAddEventResponsibility(event.eventId));
    });
  }

  Future<AddEventResponsibilityState> _mapAddEventResponsibility(
      String eventId) async {
    try {
      await _responsibilitiesRepository.addEventResponsibility(
          eventId,
          HangEventResponsibility(
              responsibilityContent: state.responsibilityContent!,
              assignedUser: state.responsibilityUser!,
              creationDate: DateTime.now()));

      return state.copyWith(
          addEventResponsibilityStateStatus: AddEventResponsibilityStateStatus
              .successfullyAddedEventResponsibility);
    } catch (_) {
      return state.copyWith(
          addEventResponsibilityStateStatus:
              AddEventResponsibilityStateStatus.error,
          errorMessage: 'Unable to save responsibility for event.');
    }
  }
}
