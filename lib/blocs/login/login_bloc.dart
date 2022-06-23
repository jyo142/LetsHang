import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/services/authentication_service.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository _userRepository;
  // constructor
  LoginBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginEmailChanged) {
      yield state.copyWith(email: event.email);
    } else if (event is LoginPasswordChanged) {
      yield state.copyWith(password: event.password);
    } else if (event is LoginRequested) {
      yield LoginSubmitLoading(state);
      yield* _mapLoginSubmitToState(event, state);
    } else {
      yield state;
    }
  }

  Stream<LoginState> _mapLoginSubmitToState(
      LoginRequested createAccountRequested, LoginState loginState) async* {
    try {
      await AuthenticationService.signInEmailPassword(
          loginState.email, loginState.password);
      HangUser? curUser =
          await _userRepository.getUserByEmail(loginState.email);
      yield LoginSuccess(loggedInUser: curUser!);
    } catch (e) {
      yield LoginError(errorMessage: "Unable to login. Please try again later");
    }
  }
}
