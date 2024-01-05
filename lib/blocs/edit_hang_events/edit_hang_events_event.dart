import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/models/hang_user_model.dart';

abstract class EditHangEventsEvent extends Equatable {
  const EditHangEventsEvent();

  @override
  List<Object> get props => [];
}

class LoadUserInvites extends EditHangEventsEvent {}

class EventNameChanged extends EditHangEventsEvent {
  const EventNameChanged({required this.eventName});

  final String eventName;

  @override
  List<Object> get props => [eventName];
}

class EventDescriptionChanged extends EditHangEventsEvent {
  const EventDescriptionChanged({required this.eventDescription});

  final String eventDescription;

  @override
  List<Object> get props => [eventDescription];
}

class EventStartDateChanged extends EditHangEventsEvent {
  const EventStartDateChanged({required this.eventStartDate});

  final DateTime eventStartDate;

  @override
  List<Object> get props => [eventStartDate];
}

class EventStartTimeChanged extends EditHangEventsEvent {
  const EventStartTimeChanged({required this.eventStartTime});

  final TimeOfDay eventStartTime;

  @override
  List<Object> get props => [eventStartTime];
}

class LimitGuestCountToggled extends EditHangEventsEvent {
  const LimitGuestCountToggled({required this.limitGuestCountValue});

  final bool limitGuestCountValue;

  @override
  List<Object> get props => [limitGuestCountValue];
}

class MaxGuestCountChanged extends EditHangEventsEvent {
  const MaxGuestCountChanged({required this.maxGuestCount});
  final int maxGuestCount;

  @override
  List<Object> get props => [maxGuestCount];
}

class EventTypeToggled extends EditHangEventsEvent {
  const EventTypeToggled({required this.eventType});
  final HangEventType eventType;

  @override
  List<Object> get props => [eventType];
}

class EventPictureChanged extends EditHangEventsEvent {
  const EventPictureChanged({required this.eventPicturePath});
  final String eventPicturePath;

  @override
  List<Object> get props => [eventPicturePath];
}

class EventPictureChangedError extends EditHangEventsEvent {
  const EventPictureChangedError({required this.eventPictureError});
  final String eventPictureError;

  @override
  List<Object> get props => [eventPictureError];
}

class EventMainDetailsSavedInitiated extends EditHangEventsEvent {}

class EventEndDateTimeChanged extends EditHangEventsEvent {
  const EventEndDateTimeChanged(
      {required this.eventEndDate, required this.eventEndTime});

  final DateTime eventEndDate;
  final TimeOfDay eventEndTime;
  @override
  List<Object> get props => [eventEndDate];
}

class EventSavedInitiated extends EditHangEventsEvent {}

class EventSearchByInviteeChanged extends EditHangEventsEvent {
  const EventSearchByInviteeChanged({required this.searchEventInviteeBy});

  final SearchUserBy searchEventInviteeBy;
  @override
  List<Object> get props => [searchEventInviteeBy];
}

class EventInviteeValueChanged extends EditHangEventsEvent {
  const EventInviteeValueChanged({required this.inviteeValue});

  final String inviteeValue;
  @override
  List<Object> get props => [inviteeValue];
}

class EventSearchByInviteeInitiated extends EditHangEventsEvent {
  const EventSearchByInviteeInitiated({required this.inviteeValue});

  final String inviteeValue;
  @override
  List<Object> get props => [inviteeValue];
}

class AddEventInviteeInitiated extends EditHangEventsEvent {
  const AddEventInviteeInitiated({required this.eventInvitee});

  final HangUser eventInvitee;

  @override
  List<Object> get props => [eventInvitee];
}

class DeleteEventInviteeInitiated extends EditHangEventsEvent {
  const DeleteEventInviteeInitiated({required this.eventInviteeUserName});

  final String eventInviteeUserName;

  @override
  List<Object> get props => [eventInviteeUserName];
}

class AddEventGroupInviteeInitiated extends EditHangEventsEvent {
  const AddEventGroupInviteeInitiated({required this.eventGroupInvitee});

  final Group eventGroupInvitee;

  @override
  List<Object> get props => [eventGroupInvitee];
}

class PopulateEventData extends EditHangEventsEvent {
  const PopulateEventData({required this.eventData});

  final HangEvent eventData;

  @override
  List<Object> get props => [eventData];
}
