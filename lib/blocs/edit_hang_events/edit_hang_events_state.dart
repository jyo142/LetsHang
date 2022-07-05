import 'package:equatable/equatable.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';

class EditHangEventsState extends Equatable {
  final String hangEventId;
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  late final DateTime eventStartDate;
  late final DateTime eventEndDate;

  // metadata
  final String searchEventInvitee;
  final SearchUserBy searchEventInviteeBy;
  late final Map<String, HangUserPreview> eventInvitees;
  late final Map<String, Group> eventGroupInvitees;

  EditHangEventsState({
    this.hangEventId = '',
    required this.eventOwner,
    this.eventName = '',
    this.eventDescription = '',
    DateTime? eventStartDate,
    DateTime? eventEndDate,
    this.searchEventInvitee = '',
    this.searchEventInviteeBy = SearchUserBy.username,
    Map<String, HangUserPreview>? eventInvitees,
    Map<String, Group>? eventGroupInvitees,
  }) {
    final dateNow = DateTime.now();
    this.eventStartDate =
        eventStartDate ?? DateTime(dateNow.year, dateNow.month, dateNow.day);
    this.eventEndDate =
        eventEndDate ?? DateTime(dateNow.year, dateNow.month, dateNow.day);
    this.eventInvitees = eventInvitees ?? {eventOwner.userName: eventOwner};
    this.eventGroupInvitees = eventGroupInvitees ?? {};
  }

  EditHangEventsState.fromState(EditHangEventsState state)
      : this(
            hangEventId: state.hangEventId,
            eventOwner: state.eventOwner,
            eventName: state.eventName,
            eventDescription: state.eventDescription,
            eventStartDate: state.eventStartDate,
            eventEndDate: state.eventEndDate,
            searchEventInvitee: state.searchEventInvitee,
            searchEventInviteeBy: state.searchEventInviteeBy,
            eventInvitees: state.eventInvitees,
            eventGroupInvitees: state.eventGroupInvitees);

  EditHangEventsState copyWith(
      {String? hangEventId,
      HangUserPreview? eventOwner,
      String? eventName,
      String? eventDescription,
      DateTime? eventStartDate,
      DateTime? eventEndDate,
      String? searchEventInvitee,
      SearchUserBy? searchEventInviteeBy,
      Map<String, HangUserPreview>? eventInvitees,
      Map<String, Group>? eventGroupInvitees}) {
    return EditHangEventsState(
        hangEventId: hangEventId ?? this.hangEventId,
        eventOwner: eventOwner ?? this.eventOwner,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        eventStartDate: eventStartDate ?? this.eventStartDate,
        eventEndDate: eventEndDate ?? this.eventEndDate,
        searchEventInvitee: searchEventInvitee ?? this.searchEventInvitee,
        searchEventInviteeBy: searchEventInviteeBy ?? this.searchEventInviteeBy,
        eventInvitees: eventInvitees ?? this.eventInvitees,
        eventGroupInvitees: eventGroupInvitees ?? this.eventGroupInvitees);
  }

  EditHangEventsState addEventInvitee(HangUserPreview newEventInvitee) {
    final newEventInvitees = Map.of(eventInvitees);
    newEventInvitees.putIfAbsent(
        newEventInvitee.userName, () => newEventInvitee);
    return copyWith(eventInvitees: newEventInvitees);
  }

  EditHangEventsState deleteEventInvitee(String eventInviteeUserName) {
    final newEventInvitees = Map.of(eventInvitees);
    newEventInvitees.remove(eventInviteeUserName);
    return copyWith(eventInvitees: newEventInvitees);
  }

  EditHangEventsState addEventGroupInvitee(Group newEventGroupInvitee) {
    final newEventGroupInvitees = Map.of(eventGroupInvitees);
    newEventGroupInvitees.putIfAbsent(
        newEventGroupInvitee.groupName, () => newEventGroupInvitee);
    return copyWith(eventGroupInvitees: newEventGroupInvitees);
  }

  EditHangEventsState deleteEventGroupInvitee(String eventInviteeGroupName) {
    final newEventGroupInvitees = Map.of(eventGroupInvitees);
    newEventGroupInvitees.remove(eventInviteeGroupName);
    return copyWith(eventGroupInvitees: newEventGroupInvitees);
  }

  @override
  List<Object?> get props => [
        hangEventId,
        eventOwner,
        eventName,
        eventDescription,
        eventStartDate,
        eventEndDate,
        searchEventInvitee,
        searchEventInviteeBy,
        eventInvitees,
        eventGroupInvitees
      ];
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
