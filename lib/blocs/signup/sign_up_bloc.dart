import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/signup/sign_up_event.dart';
import 'package:letshang/blocs/signup/sign_up_state.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/services/authentication_service.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;
  // constructor
  SignUpBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignUpState()) {
    on<UserNameChanged>((event, emit) {
      emit(state.copyWith(userName: event.userName));
    });
    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });
    on<ConfirmPasswordChanged>((event, emit) {
      emit(state.copyWith(confirmPassword: event.confirmPassword));
    });
    on<EmailPasswordSubmitted>((event, emit) {
      emit(SignUpEmailPasswordSubmitLoading(state));
    });
    on<EmailPasswordSubmitted>((event, emit) async {
      emit(SignUpEmailPasswordSubmitLoading(state));
      emit(await _mapEmailPasswordSubmitToState(event, state));
    });
    on<NameChanged>((event, emit) {
      emit(state.copyWith(name: event.name));
    });
    on<EmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });
    on<PhoneNumberChanged>((event, emit) {
      emit(state.copyWith(name: event.phoneNumber));
    });
  }

  Future<SignUpState> _mapEmailPasswordSubmitToState(
      EmailPasswordSubmitted emailPasswordSubmitted,
      SignUpState signUpState) async {
    if (signUpState.email == null ||
        signUpState.email.isEmpty ||
        signUpState.password == null ||
        signUpState.password!.isEmpty ||
        signUpState.confirmPassword == null ||
        signUpState.confirmPassword!.isEmpty) {
      return SignUpError(signUpState,
          errorMessage:
              "Missing data. Please make sure to fill out all data before continuing.");
    }
    if (signUpState.password != signUpState.confirmPassword) {
      return SignUpError(signUpState,
          errorMessage:
              "Passwords do not match. Please make sure the passwords match before continuing.");
    }
    HangUser? existingEmailUser =
        await _userRepository.getUserByEmail(signUpState.email);
    if (existingEmailUser == null) {
      // didnt find user in our db, create one
      try {
        await AuthenticationService.createEmailPasswordAccount(
            signUpState.email, signUpState.password!);
        HangUser newUser =
            HangUser(userName: signUpState.userName, email: signUpState.email);
        await _userRepository.addUser(newUser);
        return SignUpEmailPasswordCreated(signUpState);
      } on Exception catch (e) {
        return SignUpError(signUpState,
            errorMessage:
                "Unable to create new account. Please try again later. ${e.toString()}");
      }
    } else {
      return SignUpError(signUpState, errorMessage: "Email already exists");
    }
  }
}
