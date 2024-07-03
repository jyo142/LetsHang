part of 'edit_hang_events_bloc.dart';

@immutable
abstract class EditHangEventsEvent extends Equatable {
  const EditHangEventsEvent();

  @override
  List<Object> get props => [];
}

class CancelIndividualEvent extends EditHangEventsEvent {
  final String eventId;

  const CancelIndividualEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
