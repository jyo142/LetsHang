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
          yield SignUpError(errorMessage: "Username already exists");
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
      yield SignUpError(
          errorMessage: "Unable to create new account. Please try again later");
    }
  }
}
