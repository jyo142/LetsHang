import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_event_preview.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/discussions/base_discussions_repository.dart';
import 'package:letshang/repositories/discussions/discussions_repository.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';

class EditHangEventsBloc
    extends Bloc<EditHangEventsEvent, EditHangEventsState> {
  final HangEventRepository _hangEventRepository;
  final BaseDiscussionsRepository _discussionsRepository;
  final BaseUserInvitesRepository _invitesRepository;
  final UserRepository _userRepository;
  final GroupRepository _groupRepository;
  final HangUserPreview creatingUser;
  final HangEvent? existingHangEvent;
  // constructor
  EditHangEventsBloc(
      {required HangEventRepository hangEventRepository,
      required this.creatingUser,
      this.existingHangEvent})
      : _hangEventRepository = hangEventRepository,
        _discussionsRepository = DiscussionsRepository(),
        _invitesRepository = UserInvitesRepository(),
        _userRepository = UserRepository(),
        _groupRepository = GroupRepository(),
        super(EditHangEventsState(
            hangEventId: existingHangEvent?.id ?? '',
            eventName: existingHangEvent?.eventName ?? '',
            eventOwner: existingHangEvent?.eventOwner ?? creatingUser,
            eventDescription: existingHangEvent?.eventDescription ?? '',
            eventStartDateTime: existingHangEvent?.eventStartDateTime,
            eventEndDateTime: existingHangEvent?.eventEndDateTime,
            eventUserInvitees: existingHangEvent?.userInvites != null
                ? {
                    for (var member in existingHangEvent!.userInvites)
                      member.user.userName: member
                  }
                : null)) {
    on<LoadUserInvites>((event, emit) async {
      if (existingHangEvent != null) {
        List<UserInvite> eventUserInvites = await _hangEventRepository
            .getUserInvitesForEvent(existingHangEvent!.id);
        // yield state.copyWith(eventUserInvitees: eventUserInvites);
      }
    });
    on<EventNameChanged>((event, emit) {
      emit(state.copyWith(eventName: event.eventName));
    });
    on<EventDescriptionChanged>((event, emit) {
      emit(state.copyWith(eventDescription: event.eventDescription));
    });
    on<EventStartDateChanged>((event, emit) {
      emit(state.copyWith(eventStartDateTime: event.eventStartDate));
    });
    on<EventStartTimeChanged>((event, emit) {
      emit(state.copyWith(eventStartTime: event.eventStartTime));
    });
    on<LimitGuestCountToggled>((event, emit) {
      emit(state.copyWith(limitGuestCount: event.limitGuestCountValue));
    });
    on<MaxGuestCountChanged>((event, emit) {
      emit(state.copyWith(maxGuestCount: event.maxGuestCount));
    });
    on<EventTypeToggled>((event, emit) {
      emit(state.copyWith(hangEventType: event.eventType));
    });
    on<EventPictureChanged>((event, emit) {
      emit(state.copyWith(photoUrl: event.eventPicturePath));
    });
    on<EventMainDetailsSavedInitiated>((event, emit) async {
      emit(EventMainDetailsSavedLoading(state));
      emit(await _mapMainEventDetailsSavedState(state));
    });
    on<EventEndDateTimeChanged>((event, emit) {
// need to combine both the DateTime and TimeOfDay
      DateTime newEventEndDateTime = DateTime(
          event.eventEndDate.year,
          event.eventEndDate.month,
          event.eventEndDate.day,
          event.eventEndTime.hour,
          event.eventEndTime.minute);

      emit(state.copyWith(eventEndDateTime: newEventEndDateTime));
    });
    on<EventSearchByInviteeChanged>((event, emit) {
      emit(state.copyWith(searchEventInviteeBy: event.searchEventInviteeBy));
    });
    on<EventInviteeValueChanged>((event, emit) {
      emit(state.copyWith(searchEventInvitee: event.inviteeValue));
    });
    on<EventSearchByInviteeInitiated>((event, emit) async {
      emit(FindEventInviteeLoading(state));
      try {
        if (state.searchEventInviteeBy == SearchUserBy.username) {
          HangUser? retValUser =
              await _userRepository.getUserByUserName(event.inviteeValue);
          emit(FindEventInviteeRetrieved(state, eventInvitee: retValUser));
        } else if (state.searchEventInviteeBy == SearchUserBy.email) {
          HangUser? retValUser =
              await _userRepository.getUserByEmail(event.inviteeValue);
          emit(FindEventInviteeRetrieved(state, eventInvitee: retValUser));
        } else if (state.searchEventInviteeBy == SearchUserBy.group) {
          Group? retValGroup =
              await _groupRepository.getGroupByName(event.inviteeValue);
          emit(FindEventGroupInviteeRetrieved(state,
              eventGroupInvitee: retValGroup));
        }
      } catch (e) {
        emit(FindEventInviteeError(state, errorMessage: "Failed to find user"));
      }
    });
    on<AddEventInviteeInitiated>((event, emit) {
      emit(state
          .addUserEventInvitee(HangUserPreview.fromUser(event.eventInvitee)));
    });
    on<AddEventGroupInviteeInitiated>((event, emit) {
      emit(state.addEventGroupInvitee(event.eventGroupInvitee));
    });
    on<PopulateEventData>((event, emit) {
      emit(EditHangEventsState.fromEventData(event.eventData));
    });
  }

  Future<EditHangEventsState> _mapMainEventDetailsSavedState(
      EditHangEventsState eventsState) async {
    try {
      HangEvent savingEvent = HangEvent(
          id: state.hangEventId,
          eventOwner: creatingUser,
          eventName: state.eventName,
          eventDescription: state.eventDescription,
          eventStartDateTime: state.eventStartDateTime != null
              ? combineDateAndTime(
                  state.eventStartDateTime!, state.eventStartTime)
              : null,
          eventEndDateTime: state.eventEndDateTime,
          currentStage: HangEventStage.addingUsers);
      HangEvent retvalHangEvent;
      if (state.hangEventId.isNotEmpty) {
        // this event is being edited if an id is present
        retvalHangEvent = await _hangEventRepository.editHangEvent(savingEvent);
        retvalHangEvent = retvalHangEvent.copyWith(
            userInvites: List.of(state.eventUserInvitees.values));
      } else {
        retvalHangEvent = await _hangEventRepository.addHangEvent(savingEvent);
        await _invitesRepository.addUserEventInvite(
            retvalHangEvent,
            UserInvite(
                user: creatingUser,
                status: InviteStatus.owner,
                title: InviteTitle.organizer,
                type: InviteType.event));
        await _discussionsRepository.addEventDiscussion(
            HangEventPreview.fromEvent(retvalHangEvent), true, []);
      }
      return EventMainDetailsSavedSuccessfully(state,
          savedEvent: retvalHangEvent);
    } catch (_) {
      return EventMainDetailsSavedError(state, error: 'Unable to save event.');
    }
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay? timeOfDay) {
    DateTime newEventStartDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      timeOfDay != null ? timeOfDay.hour : 0,
      timeOfDay != null ? timeOfDay.minute : 0,
    );
    return newEventStartDateTime;
  }
}
