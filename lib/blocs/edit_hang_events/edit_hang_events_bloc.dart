import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_event.dart';
import 'package:letshang/blocs/edit_hang_events/edit_hang_events_state.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/repositories/group/group_repository.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';

class EditHangEventsBloc
    extends Bloc<EditHangEventsEvent, EditHangEventsState> {
  final HangEventRepository _hangEventRepository;
  final BaseUserInvitesRepository _invitesRepository;
  final UserRepository _userRepository;
  final GroupRepository _groupRepository;
  StreamSubscription? _hangEventSubscription;
  final HangUserPreview creatingUser;
  final HangEvent? existingHangEvent;
  // constructor
  EditHangEventsBloc(
      {required HangEventRepository hangEventRepository,
      required this.creatingUser,
      this.existingHangEvent})
      : _hangEventRepository = hangEventRepository,
        _invitesRepository = UserInvitesRepository(),
        _userRepository = UserRepository(),
        _groupRepository = GroupRepository(),
        super(EditHangEventsState(
            eventName: existingHangEvent?.eventName ?? '',
            eventOwner: existingHangEvent?.eventOwner ?? creatingUser,
            eventDescription: existingHangEvent?.eventDescription ?? '',
            eventStartDate: existingHangEvent?.eventStartDate,
            eventEndDate: existingHangEvent?.eventEndDate,
            eventUserInvitees: existingHangEvent?.userInvites != null
                ? {
                    for (var member in existingHangEvent!.userInvites)
                      member.user.userName: member
                  }
                : null));

  @override
  Stream<EditHangEventsState> mapEventToState(
      EditHangEventsEvent event) async* {
    if (event is LoadUserInvites) {
      if (existingHangEvent != null) {
        List<UserInvite> eventUserInvites = await _hangEventRepository
            .getUserInvitesForEvent(existingHangEvent!.id);
        // yield state.copyWith(eventUserInvitees: eventUserInvites);
      }
    } else if (event is EventNameChanged) {
      yield state.copyWith(eventName: event.eventName);
    } else if (event is EventDescriptionChanged) {
      yield state.copyWith(eventDescription: event.eventDescription);
    } else if (event is EventStartDateChanged) {
      yield state.copyWith(eventStartDate: event.eventStartDate);
    } else if (event is EventStartTimeChanged) {
      yield state.copyWith(eventStartTime: event.eventStartTime);
    } else if (event is LimitGuestCountToggled) {
      yield state.copyWith(limitGuestCount: event.limitGuestCountValue);
    } else if (event is MaxGuestCountChanged) {
      yield state.copyWith(maxGuestCount: event.maxGuestCount);
    } else if (event is EventTypeToggled) {
      yield state.copyWith(hangEventType: event.eventType);
    } else if (event is EventPictureChanged) {
      yield state.copyWith(photoUrl: event.eventPicturePath);
    } else if (event is EventMainDetailsSavedInitiated) {
      yield EventMainDetailsSavedLoading(state);
      yield* _mapMainEventDetailsSavedState(state);
    } else if (event is EventEndDateTimeChanged) {
      // need to combine both the DateTime and TimeOfDay
      DateTime newEventEndDateTime = DateTime(
          event.eventEndDate.year,
          event.eventEndDate.month,
          event.eventEndDate.day,
          event.eventEndTime.hour,
          event.eventEndTime.minute);

      yield state.copyWith(eventEndDate: newEventEndDateTime);
    } else if (event is EventSavedInitiated) {
      yield* _mapEventSavedState(event, state);
    }
    // events to do with finding an event invitee
    else if (event is EventSearchByInviteeChanged) {
      yield state.copyWith(searchEventInviteeBy: event.searchEventInviteeBy);
    } else if (event is EventInviteeValueChanged) {
      yield state.copyWith(searchEventInvitee: event.inviteeValue);
    } else if (event is EventSearchByInviteeInitiated) {
      yield FindEventInviteeLoading(state);
      try {
        if (state.searchEventInviteeBy == SearchUserBy.username) {
          HangUser? retValUser =
              await _userRepository.getUserByUserName(event.inviteeValue);
          yield FindEventInviteeRetrieved(state, eventInvitee: retValUser);
        } else if (state.searchEventInviteeBy == SearchUserBy.email) {
          HangUser? retValUser =
              await _userRepository.getUserByEmail(event.inviteeValue);
          yield FindEventInviteeRetrieved(state, eventInvitee: retValUser);
        } else if (state.searchEventInviteeBy == SearchUserBy.group) {
          Group? retValGroup =
              await _groupRepository.getGroupByName(event.inviteeValue);
          yield FindEventGroupInviteeRetrieved(state,
              eventGroupInvitee: retValGroup);
        }
      } catch (e) {
        yield FindEventInviteeError(state, errorMessage: "Failed to find user");
      }
    } else if (event is AddEventInviteeInitiated) {
      yield state
          .addUserEventInvitee(HangUserPreview.fromUser(event.eventInvitee));
    } else if (event is AddEventGroupInviteeInitiated) {
      yield state.addEventGroupInvitee(event.eventGroupInvitee);
    } else {
      yield state;
    }
  }

  Stream<EditHangEventsState> _mapMainEventDetailsSavedState(
      EditHangEventsState eventsState) async* {
    try {
      HangEvent savingEvent = HangEvent(
          id: existingHangEvent?.id ?? "",
          eventOwner: creatingUser,
          eventName: state.eventName,
          eventDescription: state.eventDescription,
          eventStartDate: state.eventStartDate,
          eventEndDate: state.eventEndDate,
          currentStage: HangEventStage.addingUsers);
      HangEvent retvalHangEvent;
      if (existingHangEvent != null) {
        // this event is being edited if an id is present
        retvalHangEvent = await _hangEventRepository.editHangEvent(savingEvent);
        retvalHangEvent = retvalHangEvent.copyWith(
            userInvites: List.of(state.eventUserInvitees.values));
        await _invitesRepository.editUserEventInvites(retvalHangEvent);
      } else {
        retvalHangEvent = await _hangEventRepository.addHangEvent(savingEvent);
        await _invitesRepository.addUserEventInvite(
            retvalHangEvent,
            UserInvite(
                user: creatingUser,
                status: InviteStatus.owner,
                type: InviteType.event));
      }
      yield EventMainDetailsSavedSuccessfully(state,
          savedEvent: retvalHangEvent);
    } catch (_) {
      yield EventMainDetailsSavedError(state, error: 'Unable to save event.');
    }
  }

  Stream<EditHangEventsState> _mapEventSavedState(
      EventSavedInitiated eventSavedEvent,
      EditHangEventsState eventsState) async* {
    _hangEventSubscription?.cancel();
    try {
      final resultEventUserInvitees = List.of(state.eventUserInvitees.values);

      HangEvent savingEvent = HangEvent(
          id: existingHangEvent?.id ?? "",
          eventOwner: creatingUser,
          eventName: state.eventName,
          eventDescription: state.eventDescription,
          eventStartDate: state.eventStartDate,
          eventEndDate: state.eventEndDate,
          userInvites: resultEventUserInvitees);
      if (existingHangEvent != null) {
        // this event is being edited if an id is present
        HangEvent editingEvent =
            await _hangEventRepository.editHangEvent(savingEvent);
        await _invitesRepository.editUserEventInvites(editingEvent);
      } else {
        HangEvent newEvent =
            await _hangEventRepository.addHangEvent(savingEvent);
        await _invitesRepository.addUserEventInvites(
            newEvent, savingEvent.userInvites);
      }
      yield EventSavedSuccessfully(state);
    } catch (_) {}
  }
}
