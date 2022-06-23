import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';

class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppLoginLoading extends AppState {}

class AppIsLoggingIn extends AppState {
  const AppIsLoggingIn({this.email = '', this.password = ''});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class AppLoginError extends AppState {
  const AppLoginError({this.errorMessage});

  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class AppUnauthenticated extends AppState {}

class AppNewUser extends AppState {
  const AppNewUser({this.firebaseUser});

  final User? firebaseUser;

  @override
  List<Object?> get props => [firebaseUser];
}

class AppAuthenticated extends AppState {
  const AppAuthenticated({required this.user});

  final HangUser user;

  @override
  List<Object> get props => [user];
}
