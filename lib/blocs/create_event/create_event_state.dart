part of 'create_event_bloc.dart';

enum CreateEventStateStatus {
  initial,
  loadingEventDetails,
  loadedEventDetails,
  loadingStep,
  submittedStep,
  nextStep,
  error
}

class CreateEventState extends Equatable {
  final Map<HangEventStage, int> stageToIndexMap = {
    HangEventStage.nameDescription: 0,
    HangEventStage.dateTime: 1,
    HangEventStage.recurringEvent: 2,
    HangEventStage.location: 2,
    HangEventStage.review: 3
  };
  late final List<CreateEventStep> createEventStateSteps;
  final CreateEventStateStatus createEventStateStatus;
  final int createEventStepIndex;
  final String hangEventId;
  final HangUserPreview eventOwner;
  final String eventName;
  final String eventDescription;
  final CreateEventYesNo? timeAndDateKnown;
  final DateTime? eventStartDateTime;
  final DateTime? eventEndDateTime;
  final TimeOfDay? eventStartTime;
  final int? durationHours;
  final CreateEventYesNo? isRecurringEvent;
  final HangEventRecurringType? recurringType;
  final int? recurringFrequency;
  final CreateEventYesNo? eventLocationKnown;
  final String? eventLocation;
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
    List<CreateEventStep>? createEventStateSteps,
    this.hangEventId = '',
    this.createEventStepIndex = 0,
    required this.eventOwner,
    this.eventName = '',
    this.eventDescription = '',
    this.timeAndDateKnown,
    this.eventStartDateTime,
    this.eventEndDateTime,
    this.eventStartTime,
    this.durationHours,
    this.isRecurringEvent,
    this.recurringType,
    this.recurringFrequency,
    this.eventLocationKnown,
    this.eventLocation,
    this.limitGuestCount = false,
    this.maxGuestCount = 0,
    this.hangEventType = HangEventType.private,
    this.photoUrl = '',
    this.searchEventInvitee = '',
    this.searchEventInviteeBy = SearchUserBy.username,
    this.formStepValidationMap = const {},
    this.errorMessage,
    Map<String, UserInvite>? eventUserInvitees,
  }) : createEventStateSteps = createEventStateSteps ??
            [
              EventNameDescriptionStep(),
              EventTimeDateStep(),
              EventLocationStep(),
              CreateEventReviewStep()
            ] {
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
            durationHours: state.durationHours,
            isRecurringEvent: state.isRecurringEvent,
            recurringType: state.recurringType,
            recurringFrequency: state.recurringFrequency,
            eventLocationKnown: state.eventLocationKnown,
            eventLocation: state.eventLocation,
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
      List<CreateEventStep>? createEventStateSteps,
      String? hangEventId,
      int? createEventStepIndex,
      HangUserPreview? eventOwner,
      String? eventName,
      String? eventDescription,
      CreateEventYesNo? timeAndDateKnown,
      DateTime? eventStartDateTime,
      DateTime? eventEndDateTime,
      TimeOfDay? eventStartTime,
      int? durationHours,
      CreateEventYesNo? isRecurringEvent,
      HangEventRecurringType? recurringType,
      int? recurringFrequency,
      CreateEventYesNo? eventLocationKnown,
      String? eventLocation,
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
        createEventStateSteps:
            createEventStateSteps ?? this.createEventStateSteps,
        createEventStepIndex: createEventStepIndex ?? this.createEventStepIndex,
        hangEventId: hangEventId ?? this.hangEventId,
        eventOwner: eventOwner ?? this.eventOwner,
        eventName: eventName ?? this.eventName,
        eventDescription: eventDescription ?? this.eventDescription,
        timeAndDateKnown: timeAndDateKnown ?? this.timeAndDateKnown,
        eventStartDateTime: eventStartDateTime ?? this.eventStartDateTime,
        eventStartTime: eventStartTime ?? this.eventStartTime,
        durationHours: durationHours ?? this.durationHours,
        isRecurringEvent: isRecurringEvent ?? this.isRecurringEvent,
        recurringType: recurringType ?? this.recurringType,
        recurringFrequency: recurringFrequency ?? this.recurringFrequency,
        eventLocationKnown: eventLocationKnown ?? this.eventLocationKnown,
        eventLocation: eventLocation ?? this.eventLocation,
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
        id: hangEventId,
        eventOwner: eventOwner,
        eventName: eventName,
        eventDescription: eventDescription,
        eventStartDateTime: eventStartDateTime,
        eventEndDateTime: eventEndDateTime,
        durationHours: durationHours,
        eventLocation: eventLocation,
        currentStage: eventStage,
        photoURL: photoUrl,
        recurringSettings: recurringType != null
            ? HangEventRecurringSettings(
                recurringType: recurringType!,
                recurringFrequency: recurringFrequency!)
            : null);
  }

  CreateEventState moveToStage(HangEventStage newStage) {
    int newStageIndex =
        stageToIndexMap.containsKey(newStage) ? stageToIndexMap[newStage]! : 0;
    if (isRecurringEvent == CreateEventYesNo.yes) {
      // the only oddity is when recurring event is populated. If recurring event is populated
      // then location step is one step up.
      int recurringEventIndex = stageToIndexMap[HangEventStage.recurringEvent]!;
      if (newStage == HangEventStage.location ||
          newStageIndex > recurringEventIndex) {
        newStageIndex += 1;
      }
    }
    return copyWith(createEventStepIndex: newStageIndex);
  }

  CreateEventState convertEventToState(HangEvent currentEvent) {
    return CreateEventState(
        createEventStateStatus: CreateEventStateStatus.loadedEventDetails,
        createEventStepIndex:
            stageToIndexMap.containsKey(currentEvent.currentStage)
                ? stageToIndexMap[currentEvent.currentStage]!
                : 0,
        hangEventId: currentEvent.id,
        eventOwner: currentEvent.eventOwner,
        eventName: currentEvent.eventName,
        eventDescription: currentEvent.eventDescription,
        timeAndDateKnown: currentEvent.eventStartDateTime != null
            ? CreateEventYesNo.yes
            : CreateEventYesNo.no,
        eventStartDateTime: currentEvent.eventStartDateTime,
        durationHours: currentEvent.durationHours,
        eventLocationKnown: currentEvent.eventLocation != null
            ? CreateEventYesNo.yes
            : CreateEventYesNo.no,
        eventLocation: currentEvent.eventLocation,
        isRecurringEvent: currentEvent.recurringSettings != null
            ? CreateEventYesNo.yes
            : CreateEventYesNo.no,
        recurringType: currentEvent.recurringSettings?.recurringType,
        recurringFrequency: currentEvent.recurringSettings?.recurringFrequency);
  }

  @override
  List<Object?> get props => [
        createEventStateStatus,
        createEventStateSteps,
        createEventStepIndex,
        hangEventId,
        eventOwner,
        eventName,
        eventDescription,
        timeAndDateKnown,
        eventStartDateTime,
        eventEndDateTime,
        eventStartTime,
        isRecurringEvent,
        recurringType,
        recurringFrequency,
        durationHours,
        eventLocationKnown,
        eventLocation,
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
