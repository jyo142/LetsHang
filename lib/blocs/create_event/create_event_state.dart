part of 'create_event_bloc.dart';

final List<CreateEventStep> createEventStateSteps = [
  EventNameDescriptionStep(),
  EventTimeDateStep()
];

enum CreateEventStateStatus {
  initial,
  loadingStep,
  submittedStep,
  nextStep,
  error
}

class CreateEventState extends Equatable {
  final CreateEventStateStatus createEventStateStatus;
  final int createEventStepIndex;
  final String hangEventId;
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  final TimeAndDateKnown? timeAndDateKnown;
  final DateTime? eventStartDateTime;
  final DateTime? eventEndDateTime;
  final TimeOfDay? eventStartTime;
  final bool limitGuestCount;
  final int? maxGuestCount;
  final HangEventType hangEventType;
  late final String? photoUrl;
  // metadata
  final String searchEventInvitee;
  final SearchUserBy searchEventInviteeBy;
  late final Map<String, UserInvite> eventUserInvitees;

  final Map<String, Map<String, String>> formStepValidationMap;
  final String? errorMessage;
  CreateEventState({
    required this.createEventStateStatus,
    this.hangEventId = '',
    this.createEventStepIndex = 0,
    required this.eventOwner,
    this.eventName = '',
    this.eventDescription = '',
    this.timeAndDateKnown,
    this.eventStartDateTime,
    this.eventEndDateTime,
    this.eventStartTime,
    this.limitGuestCount = false,
    this.maxGuestCount = 0,
    this.hangEventType = HangEventType.private,
    this.photoUrl = '',
    this.searchEventInvitee = '',
    this.searchEventInviteeBy = SearchUserBy.username,
    this.formStepValidationMap = const {},
    this.errorMessage,
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

  CreateEventState.fromState(CreateEventState state)
      : this(
            createEventStateStatus: state.createEventStateStatus,
            createEventStepIndex: state.createEventStepIndex,
            hangEventId: state.hangEventId,
            eventOwner: state.eventOwner,
            eventName: state.eventName,
            timeAndDateKnown: state.timeAndDateKnown,
            eventDescription: state.eventDescription,
            eventStartDateTime: state.eventStartDateTime,
            eventEndDateTime: state.eventEndDateTime,
            eventStartTime: state.eventStartTime,
            limitGuestCount: state.limitGuestCount,
            maxGuestCount: state.maxGuestCount,
            hangEventType: state.hangEventType,
            photoUrl: state.photoUrl,
            searchEventInvitee: state.searchEventInvitee,
            searchEventInviteeBy: state.searchEventInviteeBy,
            eventUserInvitees: state.eventUserInvitees,
            formStepValidationMap: state.formStepValidationMap,
            errorMessage: state.errorMessage);

  CreateEventState copyWith(
      {CreateEventStateStatus? createEventStateStatus,
      String? hangEventId,
      int? createEventStepIndex,
      HangUserPreview? eventOwner,
      String? eventName,
      String? eventDescription,
      TimeAndDateKnown? timeAndDateKnown,
      DateTime? eventStartDateTime,
      DateTime? eventEndDateTime,
      TimeOfDay? eventStartTime,
      bool? limitGuestCount,
      int? maxGuestCount,
      HangEventType? hangEventType,
      String? photoUrl,
      String? searchEventInvitee,
      SearchUserBy? searchEventInviteeBy,
      Map<String, UserInvite>? eventUserInvitees,
      Map<String, Map<String, String>>? formStepValidationMap,
      String? errorMessage}) {
    return CreateEventState(
        createEventStateStatus:
            createEventStateStatus ?? this.createEventStateStatus,
        createEventStepIndex: createEventStepIndex ?? this.createEventStepIndex,
        hangEventId: hangEventId ?? this.hangEventId,
        eventOwner: eventOwner ?? this.eventOwner,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        timeAndDateKnown: timeAndDateKnown ?? this.timeAndDateKnown,
        eventStartDateTime: eventStartDateTime ?? this.eventStartDateTime,
        eventStartTime: eventStartTime ?? this.eventStartTime,
        limitGuestCount: limitGuestCount ?? this.limitGuestCount,
        maxGuestCount: maxGuestCount ?? this.maxGuestCount,
        hangEventType: hangEventType ?? this.hangEventType,
        eventEndDateTime: eventEndDateTime ?? this.eventEndDateTime,
        photoUrl: photoUrl ?? this.photoUrl,
        searchEventInvitee: searchEventInvitee ?? this.searchEventInvitee,
        searchEventInviteeBy: searchEventInviteeBy ?? this.searchEventInviteeBy,
        eventUserInvitees: eventUserInvitees ?? this.eventUserInvitees,
        formStepValidationMap:
            formStepValidationMap ?? this.formStepValidationMap,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  bool isValidEvent() {
    return eventName.isNotEmpty;
  }

  CreateEventState addUserEventInvitee(HangUserPreview newEventInvitee) {
    final newEventInvitees = Map.of(eventUserInvitees);
    newEventInvitees.putIfAbsent(
        newEventInvitee.userName,
        () => UserInvite(
            user: newEventInvitee,
            status: InviteStatus.pending,
            type: InviteType.event));
    return copyWith(eventUserInvitees: newEventInvitees);
  }

  CreateEventState deleteUserEventInvitee(String eventInviteeUserName) {
    final newEventInvitees = Map.of(eventUserInvitees);
    newEventInvitees.remove(eventInviteeUserName);
    return copyWith(eventUserInvitees: newEventInvitees);
  }

  CreateEventState addEventGroupInvitee(Group newEventGroupInvitee) {
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

  HangEvent createHangEvent(HangEventStage eventStage) {
    return HangEvent(
        id: "",
        eventOwner: eventOwner,
        eventName: eventName,
        eventDescription: eventDescription,
        eventStartDateTime: eventStartDateTime,
        eventEndDateTime: eventEndDateTime,
        currentStage: eventStage,
        photoURL: photoUrl);
  }

  @override
  List<Object?> get props => [
        createEventStateStatus,
        createEventStepIndex,
        hangEventId,
        eventOwner,
        eventName,
        eventDescription,
        timeAndDateKnown,
        eventStartDateTime,
        eventEndDateTime,
        eventStartTime,
        limitGuestCount,
        maxGuestCount,
        hangEventType,
        photoUrl,
        searchEventInvitee,
        searchEventInviteeBy,
        eventUserInvitees,
        formStepValidationMap,
        errorMessage
      ];
}