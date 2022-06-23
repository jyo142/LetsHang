part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String email;
  final String password;

  LoginState({this.email = '', this.password = ''}) {}

  LoginState copyWith({String? email, String? password}) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [email, password];
}

class LoginSubmitLoading extends LoginState {
  LoginSubmitLoading(LoginState state)
      : super(email: state.email, password: state.password);
}

class LoginSuccess extends LoginState {
  LoginSuccess({required this.loggedInUser});

  final HangUser loggedInUser;

  @override
  List<Object> get props => [loggedInUser];
}

class LoginError extends LoginState {
  final String errorMessage;

  LoginError({required this.errorMessage}) {}

  @override
  List<Object> get props => [errorMessage];
}
