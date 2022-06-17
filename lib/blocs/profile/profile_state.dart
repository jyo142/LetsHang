import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';

class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInfoLoading extends ProfileState {
  final String userName;

  ProfileInfoLoading({required this.userName}) {}

  @override
  List<Object> get props => [userName];
}

class ProfileInfoError extends ProfileState {
  final String errorMessage;

  ProfileInfoError({required this.errorMessage}) {}

  @override
  List<Object> get props => [errorMessage];
}

class ProfileInfoRetrieved extends ProfileState {
  final HangUser hangUser;

  ProfileInfoRetrieved({required this.hangUser}) {}

  @override
  List<Object> get props => [hangUser];
}
