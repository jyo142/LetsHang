import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class UserNameChanged extends SignUpEvent {
  const UserNameChanged(this.userName);

  final String userName;

  @override
  List<Object> get props => [userName];
}

class CreateAccountRequested extends SignUpEvent {
  final User? firebaseUser;
  final String userName;

  CreateAccountRequested({this.firebaseUser, this.userName = ''}) {}

  @override
  List<Object?> get props => [firebaseUser, userName];
}
