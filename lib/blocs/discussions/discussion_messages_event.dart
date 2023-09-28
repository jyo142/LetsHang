part of 'discussion_messages_bloc.dart';

abstract class DiscussionMessagesEvent extends Equatable {
  const DiscussionMessagesEvent();

  @override
  List<Object> get props => [];
}

class LoadDiscussionMessages extends DiscussionMessagesEvent {}

class DiscussionMessageChanged extends DiscussionMessagesEvent {
  final String newMessage;

  const DiscussionMessageChanged(this.newMessage);

  @override
  List<Object> get props => [newMessage];
}

class DiscussionMessagesReceived extends DiscussionMessagesEvent {
  final List<DiscussionMessage> receivedDiscussionMessages;

  const DiscussionMessagesReceived(this.receivedDiscussionMessages);

  @override
  List<Object> get props => [receivedDiscussionMessages];
}

class SendDiscussionMessage extends DiscussionMessagesEvent {}
