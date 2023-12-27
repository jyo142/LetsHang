part of 'add_event_responsibility_bloc.dart';

enum AddEventResponsibilityStateStatus {
  initial,
  addingEventResponsibility,
  successfullyAddedEventResponsibility,
  error
}

class AddEventResponsibilityState extends Equatable {
  final AddEventResponsibilityStateStatus addEventResponsibilityStateStatus;
  final HangUserPreview? responsibilityUser;
  final String? responsibilityUserError;
  final String? responsibilityContent;
  final String? errorMessage;

  const AddEventResponsibilityState(
      {required this.addEventResponsibilityStateStatus,
      this.responsibilityUser,
      this.responsibilityUserError,
      this.responsibilityContent,
      this.errorMessage});

  AddEventResponsibilityState copyWith(
      {AddEventResponsibilityStateStatus? addEventResponsibilityStateStatus,
      HangUserPreview? responsibilityUser,
      String? responsibilityUserError,
      String? responsibilityContent,
      String? errorMessage}) {
    return AddEventResponsibilityState(
        addEventResponsibilityStateStatus: addEventResponsibilityStateStatus ??
            this.addEventResponsibilityStateStatus,
        responsibilityUser: responsibilityUser ?? this.responsibilityUser,
        responsibilityUserError:
            responsibilityUserError ?? this.responsibilityUserError,
        responsibilityContent:
            responsibilityContent ?? this.responsibilityContent,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        addEventResponsibilityStateStatus,
        responsibilityUser,
        responsibilityUserError,
        responsibilityContent,
        errorMessage
      ];
}
