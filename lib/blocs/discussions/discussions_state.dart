part of 'discussions_bloc.dart';

enum DiscussionsStateStatus {
  initial,
  loadingEventDiscussions,
  retrievedEventDiscussions,
  error
}

class DiscussionsState extends Equatable {
  final DiscussionsStateStatus discussionsStateStatus;
  final List<DiscussionModel>? allEventDiscussions;
  final String? errorMessage;

  DiscussionsState(
      {required this.discussionsStateStatus,
      this.allEventDiscussions,
      this.errorMessage});

  DiscussionsState copyWith(
      {DiscussionsStateStatus? discussionsStateStatus,
      List<DiscussionModel>? allEventDiscussions,
      String? errorMessage}) {
    return DiscussionsState(
        discussionsStateStatus:
            discussionsStateStatus ?? this.discussionsStateStatus,
        allEventDiscussions: allEventDiscussions ?? this.allEventDiscussions,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [discussionsStateStatus, allEventDiscussions, errorMessage];
}
