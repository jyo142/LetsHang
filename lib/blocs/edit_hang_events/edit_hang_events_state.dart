import 'package:equatable/equatable.dart';
import 'package:letshang/models/group_model.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';

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
  late final Map<String, UserInvite> eventUserInvitees;

  EditHangEventsState({
    this.hangEventId = '',
    required this.eventOwner,
    this.eventName = '',
    this.eventDescription = '',
    DateTime? eventStartDate,
    DateTime? eventEndDate,
    this.searchEventInvitee = '',
    this.searchEventInviteeBy = SearchUserBy.username,
    Map<String, UserInvite>? eventUserInvitees,
  }) {
    final dateNow = DateTime.now();
    this.eventStartDate =
        eventStartDate ?? DateTime(dateNow.year, dateNow.month, dateNow.day);
    this.eventEndDate =
        eventEndDate ?? DateTime(dateNow.year, dateNow.month, dateNow.day);
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
      String? searchEventInvitee,
      SearchUserBy? searchEventInviteeBy,
      Map<String, UserInvite>? eventUserInvitees}) {
    return EditHangEventsState(
        hangEventId: hangEventId ?? this.hangEventId,
        eventOwner: eventOwner ?? this.eventOwner,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        eventStartDate: eventStartDate ?? this.eventStartDate,
        eventEndDate: eventEndDate ?? this.eventEndDate,
        searchEventInvitee: searchEventInvitee ?? this.searchEventInvitee,
        searchEventInviteeBy: searchEventInviteeBy ?? this.searchEventInviteeBy,
        eventUserInvitees: eventUserInvitees ?? this.eventUserInvitees);
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
        searchEventInvitee,
        searchEventInviteeBy,
        eventUserInvitees,
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
