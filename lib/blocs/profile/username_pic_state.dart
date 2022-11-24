import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';

class UsernamePicState extends Equatable {
  final String? username;
  final String email;
  final String? profilePicPath;
  const UsernamePicState(
      {required this.username, required this.email, this.profilePicPath});

  UsernamePicState.fromState(UsernamePicState state)
      : this(
          username: state.username,
          email: state.email,
          profilePicPath: state.profilePicPath,
        );

  UsernamePicState copyWith(
      {String? username, String? email, String? profilePicPath}) {
    return UsernamePicState(
        username: username ?? this.username,
        email: email ?? this.email,
        profilePicPath: profilePicPath ?? this.profilePicPath);
  }

  @override
  List<Object?> get props => [username, email, profilePicPath];
}

class UsernamePicLoading extends UsernamePicState {
  const UsernamePicLoading({required String? username, required String email})
      : super(username: username, email: email);
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

class UsernamePicSubmitSuccessful extends UsernamePicState {
  UsernamePicSubmitSuccessful(UsernamePicState state) : super.fromState(state);
}

class UsernamePicSubmitError extends UsernamePicState {
  final String errorMessage;

  UsernamePicSubmitError(UsernamePicState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}
