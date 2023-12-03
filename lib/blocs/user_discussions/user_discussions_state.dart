part of 'user_discussions_bloc.dart';

enum UserDiscussionsStateStatus {
  initial,
  loadingUserDiscussions,
  retrievedUserDiscussions,
  error
}

class UserDiscussionsState extends Equatable {
  final UserDiscussionsStateStatus discussionsStateStatus;
  final List<UserDiscussionsModel> allUserDiscussions;
  final String? errorMessage;

  UserDiscussionsState(
      {required this.discussionsStateStatus,
      this.allUserDiscussions = const [],
      this.errorMessage});

  UserDiscussionsState copyWith(
      {UserDiscussionsStateStatus? discussionsStateStatus,
      List<UserDiscussionsModel>? allUserDiscussions,
      String? errorMessage}) {
    return UserDiscussionsState(
        discussionsStateStatus:
            discussionsStateStatus ?? this.discussionsStateStatus,
        allUserDiscussions: allUserDiscussions ?? this.allUserDiscussions,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props =>
      [discussionsStateStatus, allUserDiscussions, errorMessage];
}
