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
  StreamSubscription? _userSubscription;
  // constructor
  SignUpBloc({required UserRepository userRepository, User? firebaseUser})
      : _userRepository = userRepository,
        super(SignUpState(firebaseUser: firebaseUser));

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is UserNameChanged) {
      yield state.copyWith(userName: event.userName);
    } else if (event is PasswordChanged) {
      yield state.copyWith(password: event.password);
    } else if (event is ConfirmPasswordChanged) {
      yield state.copyWith(confirmPassword: event.confirmPassword);
    } else if (event is EmailPasswordSubmitted) {
      yield SignUpEmailPasswordSubmitLoading(state);
      yield* _mapEmailPasswordSubmitToState(event, state);
    } else if (event is NameChanged) {
      yield state.copyWith(name: event.name);
    } else if (event is EmailChanged) {
      yield state.copyWith(email: event.email);
    } else if (event is PhoneNumberChanged) {
      yield state.copyWith(name: event.phoneNumber);
    } else if (event is CreateAccountRequested) {
      yield SignUpSubmitLoading(state);
      yield* _mapSignupSubmitToState(event, state);
    } else {
      yield state;
    }
  }

  Stream<SignUpState> _mapEmailPasswordSubmitToState(
      EmailPasswordSubmitted emailPasswordSubmitted,
      SignUpState signUpState) async* {
    try {
      if (signUpState.email == null ||
          signUpState.email!.isEmpty ||
          signUpState.password == null ||
          signUpState.password!.isEmpty ||
          signUpState.confirmPassword == null ||
          signUpState.confirmPassword!.isEmpty) {
        yield SignUpError(signUpState,
            errorMessage:
                "Missing data. Please make sure to fill out all data before continuing.");
        return;
      }
      if (signUpState.password != signUpState.confirmPassword) {
        yield SignUpError(signUpState,
            errorMessage:
                "Passwords do not match. Please make sure the passwords match before continuing.");
        return;
      }
      HangUser? existingEmailUser =
          await _userRepository.getUserByEmail(signUpState.email!);
      if (existingEmailUser == null) {
        // didnt find user in our db, create one
        yield SignUpEmailPasswordCreated(signUpState);
      } else {
        yield SignUpError(signUpState, errorMessage: "Email already exists");
      }
    } catch (e) {
      yield SignUpError(signUpState,
          errorMessage: "Unable to create new account. Please try again later");
    }
  }

  Stream<SignUpState> _mapSignupSubmitToState(
      CreateAccountRequested createAccountRequested,
      SignUpState signUpState) async* {
    try {
      if (signUpState.firebaseUser != null) {
        // user came through the firebase signup flow
        HangUser? existingUserNameUser =
            await _userRepository.getUserByUserName(signUpState.userName);
        if (existingUserNameUser == null) {
          // didnt find user in our db, create one
          HangUser curHangUser;
          curHangUser = HangUser.fromFirebaseUser(
              signUpState.userName, signUpState.firebaseUser!);
          await _userRepository.addFirebaseUser(
              signUpState.userName, signUpState.firebaseUser!);

          yield SignUpUserCreated(user: curHangUser);
        } else {
          yield SignUpError(signUpState,
              errorMessage: "Username already exists");
        }
      } else {
        // user came through normal create account flow
        await AuthenticationService.createEmailPasswordAccount(
            signUpState.email!, signUpState.password!);
        HangUser newUser = HangUser(
            name: signUpState.name,
            userName: signUpState.userName,
            email: signUpState.email,
            phoneNumber: signUpState.phoneNumber);
        await _userRepository.addUser(newUser);
        yield SignUpUserCreated(user: newUser);
      }
    } catch (e) {
      yield SignUpError(signUpState,
          errorMessage: "Unable to create new account. Please try again later");
    }
  }
}
