import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';

enum AppStateStatus {
  initial,
  loginLoading,
  isLoggingIn,
  loginError,
  unauthenticated,
  newUser,
  newFirebaseUser,
  returnedUserError,
  authenticated
}

class AppState extends Equatable {
  final AppStateStatus appStateStatus;

  final String? loggingInEmail;
  final String? loggingInPassword;

  final String? errorMessage;
  final User? firebaseUser;
  final HangUser? authenticatedUser;
  const AppState(
      {required this.appStateStatus,
      this.loggingInEmail,
      this.loggingInPassword,
      this.firebaseUser,
      this.authenticatedUser,
      this.errorMessage});

  AppState copyWith(
      {AppStateStatus? appStateStatus,
      String? loggingInEmail,
      String? loggingInPassword,
      String? errorMessage,
      User? firebaseUser,
      HangUser? authenticatedUser}) {
    return AppState(
        appStateStatus: appStateStatus ?? this.appStateStatus,
        loggingInEmail: loggingInEmail ?? this.loggingInEmail,
        loggingInPassword: loggingInPassword ?? this.loggingInPassword,
        errorMessage: errorMessage ?? this.errorMessage,
        firebaseUser: firebaseUser ?? this.firebaseUser,
        authenticatedUser: authenticatedUser ?? this.authenticatedUser);
  }

  @override
  List<Object?> get props => [
        appStateStatus,
        loggingInEmail,
        loggingInPassword,
        errorMessage,
        firebaseUser,
        authenticatedUser
      ];
}
