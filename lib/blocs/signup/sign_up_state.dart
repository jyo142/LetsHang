import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';

class SignUpState extends Equatable {
  final User? firebaseUser;
  final String userName;
  final String? name;
  final String? email;
  final String? phoneNumber;

  SignUpState(
      {this.firebaseUser,
      this.userName = '',
      this.name = '',
      this.email = '',
      this.phoneNumber = ''}) {}

  SignUpState copyWith(
      {User? firebaseUser,
      String? userName,
      String? name,
      String? email,
      String? phoneNumber}) {
    return SignUpState(
        firebaseUser: firebaseUser ?? this.firebaseUser,
        userName: userName ?? this.userName,
        name: name ?? this.name,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber);
  }

  @override
  List<Object?> get props => [firebaseUser, userName];
}

class SignUpSubmitLoading extends SignUpState {
  SignUpSubmitLoading({firebaseUser, userName = ''})
      : super(firebaseUser: firebaseUser, userName: userName);
  @override
  List<Object?> get props => [firebaseUser, userName];
}

class SignUpError extends SignUpState {
  final String errorMessage;

  SignUpError({required this.errorMessage}) {}

  @override
  List<Object> get props => [errorMessage];
}

class SignUpUserCreated extends SignUpState {
  SignUpUserCreated({required this.user});

  final HangUser user;

  @override
  List<Object> get props => [user];
}
