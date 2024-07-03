part of 'edit_hang_events_bloc.dart';

enum EditHangEventsStateStatus {
  initial,
  loading,
  hangEventsRetrieved,
  individualEventRetrieved,
  cancellingEvent,
  eventCancelledSuccessfully,
  error
}

@immutable
class EditHangEventsState extends Equatable {
  final EditHangEventsStateStatus editHangEventsStateStatus;
  final String? errorMessage;
  const EditHangEventsState({
    required this.editHangEventsStateStatus,
    this.errorMessage,
  });

  EditHangEventsState copyWith({
    EditHangEventsStateStatus? editHangEventsStateStatus,
    HangEvent? individualHangEvent,
  }) {
    return EditHangEventsState(
        editHangEventsStateStatus:
            editHangEventsStateStatus ?? this.editHangEventsStateStatus,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        editHangEventsStateStatus,
        errorMessage,
      ];
}
