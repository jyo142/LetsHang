part of 'discussion_messages_bloc.dart';

enum DiscussionMessagesStateStatus {
  initial,
  loadingDiscussionMessages,
  retrievedDiscussionMessages,
  sendingDiscussionMessage,
  messageSentSuccessfully,
  error
}

class DiscussionMessagesState extends Equatable {
  final DiscussionMessagesStateStatus discussionMessagesStateStatus;
  final List<DiscussionMessage> discussionMessages;
  final String? currentMessage;
  final String? errorMessage;

  DiscussionMessagesState(
      {required this.discussionMessagesStateStatus,
      this.discussionMessages = const [],
      this.currentMessage,
      this.errorMessage});

  DiscussionMessagesState copyWith(
      {DiscussionMessagesStateStatus? discussionMessagesStateStatus,
      List<DiscussionMessage>? discussionMessages,
      String? currentMessage,
      String? errorMessage}) {
    return DiscussionMessagesState(
        discussionMessagesStateStatus:
            discussionMessagesStateStatus ?? this.discussionMessagesStateStatus,
        discussionMessages: discussionMessages ?? this.discussionMessages,
        currentMessage: currentMessage ?? this.currentMessage,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        discussionMessagesStateStatus,
        discussionMessages,
        currentMessage,
        errorMessage
      ];
}
