part of 'add_event_responsibility_bloc.dart';

abstract class AddEventResponsibilityEvent extends Equatable {
  const AddEventResponsibilityEvent();

  @override
  List<Object> get props => [];
}

class ResponsibilityUserChanged extends AddEventResponsibilityEvent {
  final HangUserPreview responsibilityUser;

  const ResponsibilityUserChanged({required this.responsibilityUser});

  @override
  List<Object> get props => [responsibilityUser];
}

class ResponsibilityContentChanged extends AddEventResponsibilityEvent {
  final String responsibilityContent;

  const ResponsibilityContentChanged({required this.responsibilityContent});

  @override
  List<Object> get props => [responsibilityContent];
}

class AddResponsibility extends AddEventResponsibilityEvent {
  final String eventId;
  final HangUserPreview creatingUser;
  const AddResponsibility({required this.eventId, required this.creatingUser});

  @override
  List<Object> get props => [eventId, creatingUser];
}
