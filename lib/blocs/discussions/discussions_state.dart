part of 'discussions_bloc.dart';

enum DiscussionsStateStatus {
  initial,
  loadingEventDiscussions,
  retrievedEventDiscussions,
  loadingGroupDiscussion,
  retrievedGroupDiscussion,
  error
}

class DiscussionsState extends Equatable {
  final DiscussionsStateStatus discussionsStateStatus;
  final List<DiscussionModel>? allEventDiscussions;
  final DiscussionModel? groupDiscussion;
  final String? errorMessage;

  const DiscussionsState(
      {required this.discussionsStateStatus,
      this.allEventDiscussions,
      this.groupDiscussion,
      this.errorMessage});

  DiscussionsState copyWith(
      {DiscussionsStateStatus? discussionsStateStatus,
      List<DiscussionModel>? allEventDiscussions,
      DiscussionModel? groupDiscussion,
      String? errorMessage}) {
    return DiscussionsState(
        discussionsStateStatus:
            discussionsStateStatus ?? this.discussionsStateStatus,
        allEventDiscussions: allEventDiscussions ?? this.allEventDiscussions,
        groupDiscussion: groupDiscussion ?? this.groupDiscussion,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        discussionsStateStatus,
        allEventDiscussions,
        groupDiscussion,
        errorMessage
      ];
}
