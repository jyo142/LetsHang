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
        super(LoginState()) {
    on<LoginEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });
    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });
    on<LoginRequested>((event, emit) async {
      emit(LoginSubmitLoading(state));
      emit(await _mapLoginSubmitToState(event, state));
    });
  }

  Future<LoginState> _mapLoginSubmitToState(
      LoginRequested createAccountRequested, LoginState loginState) async {
    try {
      await AuthenticationService.signInEmailPassword(
          loginState.email, loginState.password);
      HangUser? curUser =
          await _userRepository.getUserByEmail(loginState.email);
      return LoginSuccess(loggedInUser: curUser!);
    } catch (e) {
      return LoginError(
          errorMessage: "Unable to login. Please try again later");
    }
  }
}
