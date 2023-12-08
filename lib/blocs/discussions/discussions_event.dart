part of 'discussions_bloc.dart';

abstract class DiscussionsEvent extends Equatable {
  const DiscussionsEvent();

  @override
  List<Object> get props => [];
}

class LoadEventDiscussions extends DiscussionsEvent {
  final String eventId;

  const LoadEventDiscussions(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class LoadGroupDiscussion extends DiscussionsEvent {
  final String groupId;

  const LoadGroupDiscussion(this.groupId);

  @override
  List<Object> get props => [groupId];
}
