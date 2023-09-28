part of 'discussions_bloc.dart';

enum DiscussionsStateStatus { initial, loadingEventDiscussions, retrievedEventDiscussions, error }

class DiscussionsState extends Equatable {
  final DiscussionsStateStatus discussionsStateStatus;
  final EventDiscussionsModel? eventDiscussionsModel;
  final String? errorMessage;

  DiscussionsState(
      {required this.discussionsStateStatus,
      this.eventDiscussionsModel,
      this.errorMessage});

  DiscussionsState copyWith(
      {DiscussionsStateStatus? discussionsStateStatus,
      EventDiscussionsModel? eventDiscussionsModel,
      String? errorMessage}) {
    return DiscussionsState(
        discussionsStateStatus:
            discussionsStateStatus ?? this.discussionsStateStatus,
        eventDiscussionsModel:
            eventDiscussionsModel ?? this.eventDiscussionsModel,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [discussionsStateStatus, eventDiscussionsModel, errorMessage];
}
