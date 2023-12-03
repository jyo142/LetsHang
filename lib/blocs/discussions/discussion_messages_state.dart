part of 'discussion_messages_bloc.dart';

enum DiscussionMessagesStateStatus {
  initial,
  loadingDiscussionMessages,
  retrievedDiscussionMessages,
  sendingDiscussionMessage,
  typingDiscussionMessage,
  messageSentSuccessfully,
  error
}

class DiscussionMessagesState extends Equatable {
  final DiscussionMessagesStateStatus discussionMessagesStateStatus;
  final List<DiscussionMessageDateGroup> messagesByDate;
  final String? currentMessage;
  final String? errorMessage;

  DiscussionMessagesState(
      {required this.discussionMessagesStateStatus,
      this.messagesByDate = const [],
      this.currentMessage,
      this.errorMessage});

  DiscussionMessagesState copyWith(
      {DiscussionMessagesStateStatus? discussionMessagesStateStatus,
      List<DiscussionMessageDateGroup>? messagesByDate,
      String? currentMessage,
      String? errorMessage}) {
    return DiscussionMessagesState(
        discussionMessagesStateStatus:
            discussionMessagesStateStatus ?? this.discussionMessagesStateStatus,
        messagesByDate: messagesByDate ?? this.messagesByDate,
        currentMessage: currentMessage ?? this.currentMessage,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [
        discussionMessagesStateStatus,
        messagesByDate,
        currentMessage,
        errorMessage
      ];
}
