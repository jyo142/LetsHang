import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';

class UsernamePicState extends Equatable {
  final String? username;
  final String? profilePicPath;
  const UsernamePicState({required this.username, this.profilePicPath});

  UsernamePicState.fromState(UsernamePicState state)
      : this(
          username: state.username,
          profilePicPath: state.profilePicPath,
        );

  UsernamePicState copyWith({String? username, String? profilePicPath}) {
    return UsernamePicState(
        username: username ?? this.username,
        profilePicPath: profilePicPath ?? this.profilePicPath);
  }

  @override
  List<Object?> get props => [username, profilePicPath];
}

class UsernamePicLoading extends UsernamePicState {
  const UsernamePicLoading({required String? username})
      : super(username: username);
}

class UsernamePicError extends UsernamePicState {
  final String errorMessage;

  UsernamePicError(UsernamePicState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}

class UsernamePicSubmitLoading extends UsernamePicState {
  UsernamePicSubmitLoading(UsernamePicState state) : super.fromState(state);
}

class UsernamePicSubmitError extends UsernamePicState {
  final String errorMessage;

  UsernamePicSubmitError(UsernamePicState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}
