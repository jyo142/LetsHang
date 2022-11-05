import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class UsernamePicEvent extends Equatable {
  const UsernamePicEvent();

  @override
  List<Object> get props => [];
}

class SubmitUsernamePicEvent extends UsernamePicEvent {}

class UsernamePicUsernameChanged extends UsernamePicEvent {
  const UsernamePicUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

class UsernamePicProfilePicChanged extends UsernamePicEvent {
  const UsernamePicProfilePicChanged({required this.profilePicPath});

  final String profilePicPath;

  @override
  List<Object> get props => [profilePicPath];
}
