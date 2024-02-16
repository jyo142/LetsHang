import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:letshang/models/events/create_event_model.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/hang_event/base_hang_event_repository.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:letshang/widgets/events/create_event/event_location_step.dart';
import 'package:letshang/widgets/events/create_event/event_name_description_step.dart';
import 'package:letshang/widgets/events/create_event/time_date_step.dart';

part 'create_event_event.dart';
part 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final HangUserPreview creatingUser;
  final BaseHangEventRepository _hangEventRepository;
  final BaseUserInvitesRepository _userInvitesRepository;
  // constructor
  CreateEventBloc({required this.creatingUser})
      : _hangEventRepository = HangEventRepository(),
        _userInvitesRepository = UserInvitesRepository(),
        super(CreateEventState(
            eventOwner: creatingUser,
            createEventStateStatus: CreateEventStateStatus.initial)) {
    on<LoadCurrentEventDetails>((event, emit) async {
      emit(state.copyWith(
          createEventStateStatus: CreateEventStateStatus.loadingEventDetails));
      emit(await _mapLoadCurrentEventDetails(event.eventId));
    });
    on<EventNameChanged>((event, emit) {
      emit(state.copyWith(eventName: event.eventName));
    });
    on<EventDescriptionChanged>((event, emit) {
      emit(state.copyWith(eventDescription: event.eventDescription));
    });
    on<TimeAndDateKnownChanged>((event, emit) {
      emit(state.copyWith(timeAndDateKnown: event.timeAndDateKnown));
    });
    on<EventStartDateChanged>((event, emit) {
      emit(state.copyWith(eventStartDateTime: event.eventStartDate));
    });
    on<EventStartTimeChanged>((event, emit) {
      emit(state.copyWith(eventStartTime: event.eventStartTime));
    });
    on<EventDurationChanged>((event, emit) {
      emit(state.copyWith(durationHours: event.durationHours));
    });
    on<EventLocationChanged>((event, emit) {
      emit(state.copyWith(eventLocation: event.eventLocation));
    });
    on<MoveNextStep>((event, emit) async {
      bool validationResult = await _validateFormStep(
          event.stepId, event.stepValidationFunction, emit);
      if (validationResult) {
        emit(state.copyWith(
            createEventStateStatus: CreateEventStateStatus.loadingStep));
        emit(await _mapSubmitFormStep(event.stepId));
        emit(state.copyWith(
            createEventStateStatus: CreateEventStateStatus.nextStep));
      }
    });
    on<MovePreviousStep>((event, emit) async {
      emit(state.copyWith(
          createEventStepIndex: state.createEventStepIndex - 1,
          createEventStateStatus: CreateEventStateStatus.nextStep));
    });
  }

  Future<CreateEventState> _mapLoadCurrentEventDetails(String eventId) async {
    HangEvent? foundEvent = await _hangEventRepository.getEventById(eventId);
    if (foundEvent != null) {
      return state.convertEventToState(foundEvent);
    }
    return state.copyWith(
        createEventStateStatus: CreateEventStateStatus.error,
        errorMessage: 'Unable to retrieve event details');
  }

  Future<bool> _validateFormStep(
      String stepId,
      Map<String, String> Function(CreateEventState) validationFunction,
      Emitter<CreateEventState> emitter) async {
    Map<String, String> validationResult = validationFunction(state);
    if (validationResult.isEmpty) {
      return true;
    }
    Map<String, Map<String, String>> formStepValidationMap =
        Map.from(state.formStepValidationMap);
    if (formStepValidationMap.containsKey(stepId)) {
      formStepValidationMap.update(stepId, (value) => validationResult);
    } else {
      formStepValidationMap.putIfAbsent(stepId, () => validationResult);
    }
    emitter(state.copyWith(formStepValidationMap: formStepValidationMap));
    return false;
  }

  Future<CreateEventState> _mapSubmitFormStep(String stepId) async {
    HangEventStage newStage;
    HangEventStage currentStage =
        HangEventStage.values.firstWhere((element) => element.name == stepId);
    try {
      switch (currentStage) {
        case HangEventStage.nameDescription:
          {
            newStage = HangEventStage.dateTime;
            break;
          }
        case HangEventStage.dateTime:
          {
            newStage = HangEventStage.location;
            break;
          }
        default:
          {
            newStage = HangEventStage.complete;
            break;
          }
      }

      if (state.hangEventId.isEmpty) {
        HangEvent createdEvent = await _hangEventRepository
            .addHangEvent(state.createHangEvent(newStage));
        await _userInvitesRepository.addUserEventInvite(
            createdEvent,
            UserInvite(
                user: creatingUser,
                status: InviteStatus.owner,
                title: InviteTitle.organizer,
                type: InviteType.event));
        return state.copyWith(
            hangEventId: createdEvent.id,
            createEventStepIndex: state.createEventStepIndex + 1,
            createEventStateStatus: CreateEventStateStatus.submittedStep);
      } else {
        await _hangEventRepository
            .editHangEvent(state.createHangEvent(newStage));
        return state.copyWith(
            createEventStepIndex: state.createEventStepIndex + 1,
            createEventStateStatus: CreateEventStateStatus.submittedStep);
      }
    } catch (_) {
      return state.copyWith(
          createEventStateStatus: CreateEventStateStatus.error,
          errorMessage: 'Unable to submit create event');
    }
  }
}
