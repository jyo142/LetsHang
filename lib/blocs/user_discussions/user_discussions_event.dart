part of 'user_discussions_bloc.dart';

abstract class UserDiscussionsEvent extends Equatable {
  const UserDiscussionsEvent();

  @override
  List<Object> get props => [];
}

class LoadUserDiscussions extends UserDiscussionsEvent {
  final String userId;

  const LoadUserDiscussions({required this.userId});

  @override
  List<Object> get props => [userId];
}
