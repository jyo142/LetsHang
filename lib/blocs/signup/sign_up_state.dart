import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:letshang/models/hang_user_model.dart';

class SignUpState extends Equatable {
  final String userName;
  final String? name;
  final String? password;
  final String? confirmPassword;
  String? get confirmPasswordError =>
      confirmPassword != password ? "Passwords do not match" : null;

  final String email;
  final String? phoneNumber;

  SignUpState(
      {this.userName = '',
      this.name = '',
      this.password = '',
      this.confirmPassword = '',
      this.email = '',
      this.phoneNumber = ''}) {}

  SignUpState.fromState(SignUpState state)
      : this(
            userName: state.userName,
            name: state.name,
            password: state.password,
            confirmPassword: state.confirmPassword,
            email: state.email,
            phoneNumber: state.phoneNumber);

  SignUpState copyWith(
      {User? firebaseUser,
      String? userName,
      String? name,
      String? password,
      String? confirmPassword,
      String? email,
      String? phoneNumber}) {
    return SignUpState(
        userName: userName ?? this.userName,
        name: name ?? this.name,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber);
  }

  @override
  List<Object?> get props =>
      [userName, name, password, confirmPassword, email, phoneNumber];
}

class SignUpSubmitLoading extends SignUpState {
  SignUpSubmitLoading(SignUpState state) : super.fromState(state);
}

class SignUpError extends SignUpState {
  final String errorMessage;

  SignUpError(SignUpState state, {required this.errorMessage})
      : super.fromState(state);

  @override
  List<Object> get props => [errorMessage];
}

class SignUpEmailPasswordSubmitLoading extends SignUpState {
  SignUpEmailPasswordSubmitLoading(SignUpState state) : super.fromState(state);
}

class SignUpEmailPasswordCreated extends SignUpState {
  SignUpEmailPasswordCreated(SignUpState state) : super.fromState(state);
}

class SignUpUserCreated extends SignUpState {
  SignUpUserCreated({required this.user});

  final HangUser user;

  @override
  List<Object> get props => [user];
}
