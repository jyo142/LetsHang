import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';

class EditHangEventsState extends Equatable {
  final String hangEventId;
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;
  final TimeOfDay? eventStartTime;
  final bool limitGuestCount;
  final int? maxGuestCount;
  final HangEventType hangEventType;
  late final String? photoUrl;
  // metadata
  final String searchEventInvitee;
  final SearchUserBy searchEventInviteeBy;
  late final Map<String, UserInvite> eventUserInvitees;

  EditHangEventsState({
    this.hangEventId = '',
    required this.eventOwner,
    this.eventName = '',
    this.eventDescription = '',
    this.eventStartDate,
    this.eventEndDate,
    this.eventStartTime,
    this.limitGuestCount = false,
    this.maxGuestCount = 0,
    this.hangEventType = HangEventType.private,
    this.photoUrl = '',
    this.searchEventInvitee = '',
    this.searchEventInviteeBy = SearchUserBy.username,
    Map<String, UserInvite>? eventUserInvitees,
  }) {
    this.eventUserInvitees = eventUserInvitees ??
        {
          eventOwner.userName: UserInvite(
              status: InviteStatus.pending,
              user: eventOwner,
              type: InviteType.event)
        };
  }

  EditHangEventsState.fromState(EditHangEventsState state)
      : this(
            hangEventId: state.hangEventId,
            eventOwner: state.eventOwner,
            eventName: state.eventName,
            eventDescription: state.eventDescription,
            eventStartDate: state.eventStartDate,
            eventEndDate: state.eventEndDate,
            eventStartTime: state.eventStartTime,
            limitGuestCount: state.limitGuestCount,
            maxGuestCount: state.maxGuestCount,
            hangEventType: state.hangEventType,
            photoUrl: state.photoUrl,
            searchEventInvitee: state.searchEventInvitee,
            searchEventInviteeBy: state.searchEventInviteeBy,
            eventUserInvitees: state.eventUserInvitees);

  EditHangEventsState copyWith(
      {String? hangEventId,
      HangUserPreview? eventOwner,
      String? eventName,
      String? eventDescription,
      DateTime? eventStartDate,
      DateTime? eventEndDate,
      TimeOfDay? eventStartTime,
      bool? limitGuestCount,
      int? maxGuestCount,
      HangEventType? hangEventType,
      String? photoUrl,
      String? searchEventInvitee,
      SearchUserBy? searchEventInviteeBy,
      Map<String, UserInvite>? eventUserInvitees}) {
    return EditHangEventsState(
        hangEventId: hangEventId ?? this.hangEventId,
        eventOwner: eventOwner ?? this.eventOwner,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        eventStartDate: eventStartDate ?? this.eventStartDate,
        eventStartTime: eventStartTime ?? this.eventStartTime,
        limitGuestCount: limitGuestCount ?? this.limitGuestCount,
        maxGuestCount: maxGuestCount ?? this.maxGuestCount,
        hangEventType: hangEventType ?? this.hangEventType,
        eventEndDate: eventEndDate ?? this.eventEndDate,
        photoUrl: photoUrl ?? this.photoUrl,
        searchEventInvitee: searchEventInvitee ?? this.searchEventInvitee,
        searchEventInviteeBy: searchEventInviteeBy ?? this.searchEventInviteeBy,
        eventUserInvitees: eventUserInvitees ?? this.eventUserInvitees);
  }

  bool isValidEvent() {
    return eventName.isNotEmpty;
  }

  EditHangEventsState addUserEventInvitee(HangUserPreview newEventInvitee) {
    final newEventInvitees = Map.of(eventUserInvitees);
    newEventInvitees.putIfAbsent(
        newEventInvitee.userName,
        () => UserInvite(
            user: newEventInvitee,
            status: InviteStatus.pending,
            type: InviteType.event));
    return copyWith(eventUserInvitees: newEventInvitees);
  }

  EditHangEventsState deleteUserEventInvitee(String eventInviteeUserName) {
    final newEventInvitees = Map.of(eventUserInvitees);
    newEventInvitees.remove(eventInviteeUserName);
    return copyWith(eventUserInvitees: newEventInvitees);
  }

  EditHangEventsState addEventGroupInvitee(Group newEventGroupInvitee) {
    final newEventInvitees = Map.of(eventUserInvitees);
    for (final member in newEventGroupInvitee.userInvites) {
      newEventInvitees.putIfAbsent(
          member.user.userName,
          () => UserInvite(
              user: member.user,
              status: InviteStatus.pending,
              type: InviteType.event));
    }
    return copyWith(eventUserInvitees: newEventInvitees);
  }

  @override
  List<Object?> get props => [
        hangEventId,
        eventOwner,
        eventName,
        eventDescription,
        eventStartDate,
        eventEndDate,
        eventStartTime,
        limitGuestCount,
        maxGuestCount,
        hangEventType,
        photoUrl,
        searchEventInvitee,
        searchEventInviteeBy,
        eventUserInvitees,
      ];
}

class EventMainDetailsSavedLoading extends EditHangEventsState {
  EventMainDetailsSavedLoading(EditHangEventsState state)
      : super.fromState(state);
}

class EventMainDetailsSavedSuccessfully extends EditHangEventsState {
  final HangEvent savedEvent;
  EventMainDetailsSavedSuccessfully(EditHangEventsState state,
      {required this.savedEvent})
      : super.fromState(state);

  @override
  List<Object> get props => [savedEvent];
}

class EventMainDetailsSavedError extends EditHangEventsState {
  final String error;
  EventMainDetailsSavedError(EditHangEventsState state, {required this.error})
      : super.fromState(state);

  @override
  List<Object> get props => [error];
}

class FindEventInviteeLoading extends EditHangEventsState {
  FindEventInviteeLoading(EditHangEventsState state) : super.fromState(state);
}

class FindEventInviteeRetrieved extends EditHangEventsState {
  final HangUser? eventInvitee;

  FindEventInviteeRetrieved(EditHangEventsState state, {this.eventInvitee})
      : super.fromState(state);

  @override
  List<Object?> get props => [eventInvitee];
}

class FindEventGroupInviteeRetrieved extends EditHangEventsState {
  final Group? eventGroupInvitee;

  FindEventGroupInviteeRetrieved(EditHangEventsState state,
      {this.eventGroupInvitee})
      : super.fromState(state);

  @override
  List<Object?> get props => [eventGroupInvitee];
}

class FindEventInviteeError extends EditHangEventsState {
  final String errorMessage;

  FindEventInviteeError(EditHangEventsState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}

class EventSavedSuccessfully extends EditHangEventsState {
  EventSavedSuccessfully(EditHangEventsState state) : super.fromState(state);
}

class EventSavedError extends EditHangEventsState {
  final String errorMessage;

  EventSavedError(EditHangEventsState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}
