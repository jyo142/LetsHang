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

class PasswordChanged extends SignUpEvent {
  const PasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordChanged extends SignUpEvent {
  const ConfirmPasswordChanged(this.confirmPassword);

  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

class EmailPasswordSubmitted extends SignUpEvent {}

class NameChanged extends SignUpEvent {
  const NameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

class EmailChanged extends SignUpEvent {
  const EmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class PhoneNumberChanged extends SignUpEvent {
  const PhoneNumberChanged(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

class CreateAccountRequested extends SignUpEvent {
  final User? firebaseUser;
  final String userName;
  final String? email;
  final String? name;
  final String? phoneNumber;

  CreateAccountRequested(
      {this.firebaseUser,
      this.userName = '',
      this.name = '',
      this.email = '',
      this.phoneNumber = ''}) {}

  @override
  List<Object?> get props => [firebaseUser, userName];
}
