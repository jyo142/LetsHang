import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/user_event_metadata.dart';

class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInfoLoading extends ProfileState {
  final String email;

  ProfileInfoLoading({required this.email}) {}

  @override
  List<Object> get props => [email];
}

class ProfileInfoError extends ProfileState {
  final String errorMessage;

  ProfileInfoError({required this.errorMessage}) {}

  @override
  List<Object> get props => [errorMessage];
}

class ProfileInfoRetrieved extends ProfileState {
  final HangUser hangUser;
  final UserEventMetadata userEventMetadata;
  ProfileInfoRetrieved(
      {required this.hangUser, required this.userEventMetadata}) {}

  @override
  List<Object> get props => [hangUser, userEventMetadata];
}
